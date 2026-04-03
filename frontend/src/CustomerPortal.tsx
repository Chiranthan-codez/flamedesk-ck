import { useCallback, useEffect, useMemo, useState } from 'react';
import './CustomerPortal.css';

const API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:3002/api';

type MenuItem = {
  item_id: number;
  item_name: string;
  description: string | null;
  price: number;
  prep_time: number;
  category: string | null;
  brand_name: string;
  avg_rating: number | null;
  rating_count: number;
};

type OrderItem = {
  item_id: number;
  item_name: string;
  quantity: number;
  subtotal: number;
};

type ExistingRating = {
  item_id: number;
  rating_value: number;
  review_text: string | null;
};

type Order = {
  order_id: number;
  total_amount: number;
  status: string;
  order_time: string;
  estimated_delivery_time: string | null;
  payment_method: string | null;
  payment_status: string | null;
  delivery_status: string | null;
  delivery_partner: string | null;
  items: OrderItem[];
  ratings: ExistingRating[];
};

type OrderFilter = 'active' | 'delivered' | 'all';

const paymentMethods = ['cash', 'card', 'upi', 'wallet'] as const;
const deliveryStages = ['pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered'] as const;

function formatCurrency(value: number) {
  return `Rs ${Number(value || 0).toFixed(2)}`;
}

function formatDateTime(value: string | null) {
  if (!value) return 'Not available';
  return new Date(value).toLocaleString('en-IN', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });
}

function normalizeLabel(value: string | null, fallback: string) {
  if (!value) return fallback;
  return value.replaceAll('_', ' ');
}

function CustomerPortal() {
  const [menu, setMenu] = useState<MenuItem[]>([]);
  const [orders, setOrders] = useState<Order[]>([]);
  const [cart, setCart] = useState<Record<number, number>>({});
  const [loading, setLoading] = useState(true);
  const [busyAction, setBusyAction] = useState('');
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');
  const [paymentChoice, setPaymentChoice] = useState<Record<number, string>>({});
  const [draftRatings, setDraftRatings] = useState<Record<string, number>>({});
  const [draftReviews, setDraftReviews] = useState<Record<string, string>>({});
  const [orderFilter, setOrderFilter] = useState<OrderFilter>('active');

  const displayName = sessionStorage.getItem('ck_display_name') || 'Customer';
  const token = sessionStorage.getItem('ck_token') || '';

  const api = useCallback(async <T,>(path: string, options: RequestInit = {}): Promise<T> => {
    const response = await fetch(`${API_BASE}${path}`, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
        ...(options.headers || {})
      }
    });

    const result = await response.json();
    if (!response.ok || result.success === false) {
      throw new Error(result.error || 'Request failed');
    }
    return result as T;
  }, [token]);

  const loadPortalData = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const [menuResult, ordersResult] = await Promise.all([
        api<{ data: MenuItem[] }>('/customer/menu'),
        api<{ data: Order[] }>('/customer/orders')
      ]);
      setMenu(menuResult.data || []);
      setOrders(ordersResult.data || []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load portal data');
    } finally {
      setLoading(false);
    }
  }, [api]);

  useEffect(() => {
    void loadPortalData();
  }, [loadPortalData]);

  const cartItems = useMemo(
    () => menu.filter(item => (cart[item.item_id] || 0) > 0),
    [cart, menu]
  );
  const cartTotal = useMemo(
    () => cartItems.reduce((sum, item) => sum + item.price * (cart[item.item_id] || 0), 0),
    [cart, cartItems]
  );
  const activeOrders = useMemo(
    () => orders.filter(order => order.status !== 'delivered'),
    [orders]
  );
  const deliveredOrders = useMemo(
    () => orders.filter(order => order.status === 'delivered'),
    [orders]
  );
  const pendingPayments = useMemo(
    () => orders.filter(order => order.payment_status !== 'completed'),
    [orders]
  );
  const totalSpend = useMemo(
    () => orders.reduce((sum, order) => sum + Number(order.total_amount || 0), 0),
    [orders]
  );
  const visibleOrders = useMemo(() => {
    if (orderFilter === 'all') return orders;
    if (orderFilter === 'delivered') return deliveredOrders;
    return activeOrders;
  }, [activeOrders, deliveredOrders, orderFilter, orders]);
  const activeOrder = activeOrders[0] || null;
  const topRatedItems = useMemo(
    () => [...menu]
      .sort((a, b) => Number(b.avg_rating || 0) - Number(a.avg_rating || 0) || b.rating_count - a.rating_count)
      .slice(0, 3),
    [menu]
  );

  function updateQty(itemId: number, nextQty: number) {
    setCart(current => {
      const copy = { ...current };
      if (nextQty <= 0) {
        delete copy[itemId];
      } else {
        copy[itemId] = nextQty;
      }
      return copy;
    });
  }

  function clearCart() {
    setCart({});
    setMessage('Cart cleared');
    setError('');
  }

  function reorderItems(order: Order) {
    setCart(current => {
      const next = { ...current };
      for (const item of order.items) {
        next[item.item_id] = (next[item.item_id] || 0) + item.quantity;
      }
      return next;
    });
    setMessage(`Items from order #${order.order_id} were added to your cart`);
    setError('');
  }

  async function placeOrder() {
    if (!cartItems.length) {
      setError('Add at least one item before placing an order');
      return;
    }

    setBusyAction('order');
    setError('');
    setMessage('');
    try {
      await api('/customer/orders', {
        method: 'POST',
        body: JSON.stringify({
          items: cartItems.map(item => ({
            item_id: item.item_id,
            quantity: cart[item.item_id]
          }))
        })
      });
      setCart({});
      setMessage('Order placed successfully');
      setOrderFilter('active');
      await loadPortalData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to place order');
    } finally {
      setBusyAction('');
    }
  }

  async function payForOrder(orderId: number) {
    const method = paymentChoice[orderId] || 'upi';
    setBusyAction(`pay-${orderId}`);
    setError('');
    setMessage('');
    try {
      await api(`/customer/orders/${orderId}/payment`, {
        method: 'PATCH',
        body: JSON.stringify({ payment_method: method })
      });
      setMessage(`Payment completed for order #${orderId}`);
      await loadPortalData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Payment failed');
    } finally {
      setBusyAction('');
    }
  }

  async function submitRatings(order: Order) {
    const ratings = order.items
      .map(item => ({
        item_id: item.item_id,
        rating_value: draftRatings[`${order.order_id}:${item.item_id}`] || 0,
        review_text: draftReviews[`${order.order_id}:${item.item_id}`]?.trim() || null
      }))
      .filter(item => item.rating_value > 0);

    if (!ratings.length) {
      setError('Choose at least one rating before submitting');
      return;
    }

    setBusyAction(`rate-${order.order_id}`);
    setError('');
    setMessage('');
    try {
      await api(`/customer/orders/${order.order_id}/ratings`, {
        method: 'POST',
        body: JSON.stringify({ ratings })
      });
      setMessage(`Ratings saved for order #${order.order_id}`);
      await loadPortalData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to submit ratings');
    } finally {
      setBusyAction('');
    }
  }

  function logout() {
    sessionStorage.removeItem('ck_auth');
    sessionStorage.removeItem('ck_user');
    sessionStorage.removeItem('ck_token');
    sessionStorage.removeItem('ck_role');
    sessionStorage.removeItem('ck_customer_id');
    sessionStorage.removeItem('ck_display_name');
    window.location.href = '/';
  }

  return (
    <div className="customer-shell">
      <div className="customer-page">
        <header className="customer-header">
          <div>
            <div className="customer-kicker">TasteTrail Customer</div>
            <br/>
            <h1>Welcome, {displayName}</h1>
            <br/>
            <p>Order from the menu, track active deliveries, complete payment, and rate delivered meals.</p>
          </div>
          <div className="header-actions">
            <button className="secondary-action" onClick={() => void loadPortalData()} disabled={loading}>
              {loading ? 'Refreshing…' : 'Refresh'}
            </button>
            <button className="customer-logout" onClick={logout}>Logout</button>
          </div>
        </header>

        {message ? <div className="customer-banner success">{message}</div> : null}
        {error ? <div className="customer-banner error">{error}</div> : null}

        {loading ? (
          <div className="customer-loading">Loading your customer portal…</div>
        ) : (
          <>
            <section className="customer-overview">
              <article className="overview-card hero-card">
                <div className="overview-label">Account Snapshot</div>
                <h2>{activeOrders.length ? `${activeOrders.length} active order${activeOrders.length > 1 ? 's' : ''}` : 'Ready for your next order'}</h2>
                <p>
                  {activeOrder
                    ? `Latest order #${activeOrder.order_id} is ${normalizeLabel(activeOrder.status, 'pending')}.`
                    : 'No live deliveries right now. Explore the menu and place your next meal order.'}
                </p>
              </article>
              <article className="overview-card">
                <div className="overview-label">Pending Payment</div>
                <strong>{pendingPayments.length}</strong>
                <span>{pendingPayments.length ? 'Orders waiting for payment' : 'All your payments are settled'}</span>
              </article>
              <article className="overview-card">
                <div className="overview-label">Delivered Orders</div>
                <strong>{deliveredOrders.length}</strong>
                <span>{deliveredOrders.length ? 'Orders completed successfully' : 'Your delivered meals will show here'}</span>
              </article>
              <article className="overview-card">
                <div className="overview-label">Total Spend</div>
                <strong>{formatCurrency(totalSpend)}</strong>
                <span>Across {orders.length} order{orders.length === 1 ? '' : 's'}</span>
              </article>
            </section>

            <div className="customer-grid">
              <section className="customer-panel customer-menu-panel">
                <div className="panel-head">
                  <div>
                    <h2>Menu</h2>
                    <p>Pick from available dishes and add them to your cart.</p>
                  </div>
                  <span>{menu.length} items</span>
                </div>
                <div className="menu-list">
                  {menu.map(item => (
                    <article className="menu-card-customer" key={item.item_id}>
                      <div className="menu-card-top">
                        <div>
                          <div className="menu-brand">{item.brand_name}</div>
                          <h3>{item.item_name}</h3>
                        </div>
                        <div className="menu-price">{formatCurrency(item.price)}</div>
                      </div>
                      <p>{item.description || 'Freshly prepared on order.'}</p>
                      <div className="menu-meta">
                        <span>{item.category || 'Kitchen Special'}</span>
                        <span>{item.prep_time} min</span>
                        <span>{item.avg_rating ? `${item.avg_rating} / 5` : 'New item'}</span>
                        <span>{item.rating_count ? `${item.rating_count} ratings` : 'Be the first to rate'}</span>
                      </div>
                      <div className="qty-row">
                        <button onClick={() => updateQty(item.item_id, (cart[item.item_id] || 0) - 1)}>-</button>
                        <span>{cart[item.item_id] || 0}</span>
                        <button onClick={() => updateQty(item.item_id, (cart[item.item_id] || 0) + 1)}>+</button>
                      </div>
                    </article>
                  ))}
                </div>
              </section>

              <aside className="customer-sidebar">
                <section className="customer-panel sidebar-panel">
                  <div className="panel-head">
                    <div>
                      <h2>Your Cart</h2>
                      <p>Review items before placing the order.</p>
                    </div>
                    <span>{cartItems.length} selections</span>
                  </div>
                  {cartItems.length ? (
                    <>
                      <div className="cart-list">
                        {cartItems.map(item => (
                          <div className="cart-line" key={item.item_id}>
                            <div>
                              <strong>{item.item_name}</strong>
                              <div>{cart[item.item_id]} x {formatCurrency(item.price)}</div>
                            </div>
                            <div>{formatCurrency(item.price * cart[item.item_id])}</div>
                          </div>
                        ))}
                      </div>
                      <div className="cart-total">Total: {formatCurrency(cartTotal)}</div>
                      <div className="button-row">
                        <button className="primary-action" onClick={placeOrder} disabled={busyAction === 'order'}>
                          {busyAction === 'order' ? 'Placing Order…' : 'Place Order'}
                        </button>
                        <button className="secondary-action" onClick={clearCart}>Clear Cart</button>
                      </div>
                    </>
                  ) : (
                    <div className="empty-state">Add menu items to create an order.</div>
                  )}
                </section>

                <section className="customer-panel sidebar-panel">
                  <div className="panel-head">
                    <div>
                      <h2>Live Order</h2>
                      <p>Track your most recent active order.</p>
                    </div>
                  </div>
                  {activeOrder ? (
                    <div className="active-order-card">
                      <div className="active-order-top">
                        <strong>Order #{activeOrder.order_id}</strong>
                        <span className="status-badge">{normalizeLabel(activeOrder.status, 'pending')}</span>
                      </div>
                      <div className="timeline">
                        {deliveryStages.map((stage, index) => {
                          const activeIndex = deliveryStages.indexOf((activeOrder.status as (typeof deliveryStages)[number]));
                          return (
                            <div key={stage} className={`timeline-step ${index <= (activeIndex >= 0 ? activeIndex : 0) ? 'done' : ''}`}>
                              <span />
                              <small>{normalizeLabel(stage, stage)}</small>
                            </div>
                          );
                        })}
                      </div>
                      <div className="active-order-meta">
                        <div>
                          <span>ETA</span>
                          <strong>{formatDateTime(activeOrder.estimated_delivery_time)}</strong>
                        </div>
                        <div>
                          <span>Delivery</span>
                          <strong>{normalizeLabel(activeOrder.delivery_status, 'unassigned')}</strong>
                        </div>
                        <div>
                          <span>Partner</span>
                          <strong>{activeOrder.delivery_partner || 'Not assigned yet'}</strong>
                        </div>
                      </div>
                    </div>
                  ) : (
                    <div className="empty-state">No active orders at the moment.</div>
                  )}
                </section>

                <section className="customer-panel sidebar-panel">
                  <div className="panel-head">
                    <div>
                      <h2>Top Picks</h2>
                      <p>Popular menu items based on customer ratings.</p>
                    </div>
                  </div>
                  <div className="top-picks">
                    {topRatedItems.length ? topRatedItems.map(item => (
                      <div className="pick-row" key={item.item_id}>
                        <div>
                          <strong>{item.item_name}</strong>
                          <div>{item.brand_name}</div>
                        </div>
                        <div className="pick-meta">
                          <strong>{item.avg_rating ? `${item.avg_rating}/5` : 'New'}</strong>
                          <span>{formatCurrency(item.price)}</span>
                        </div>
                      </div>
                    )) : (
                      <div className="empty-state">Rated menu items will appear here.</div>
                    )}
                  </div>
                </section>
              </aside>

              <section className="customer-panel customer-orders">
                <div className="panel-head panel-head-stack">
                  <div>
                    <h2>Your Orders</h2>
                    <p>Track statuses, complete pending payments, reorder favourites, and rate delivered items.</p>
                  </div>
                  <div className="order-toolbar">
                    <div className="filter-pills">
                      {(['active', 'delivered', 'all'] as OrderFilter[]).map(filter => (
                        <button
                          key={filter}
                          className={`filter-pill ${orderFilter === filter ? 'active' : ''}`}
                          onClick={() => setOrderFilter(filter)}
                        >
                          {filter === 'active' ? 'Active' : filter === 'delivered' ? 'Delivered' : 'All Orders'}
                        </button>
                      ))}
                    </div>
                    <span>{visibleOrders.length} shown</span>
                  </div>
                </div>
                <div className="order-list">
                  {visibleOrders.length ? visibleOrders.map(order => {
                    const hasExistingRatings = order.ratings.length > 0;
                    const paymentPending = !order.payment_status || order.payment_status !== 'completed';

                    return (
                      <article className="order-card-customer" key={order.order_id}>
                        <div className="order-head">
                          <div>
                            <h3>Order #{order.order_id}</h3>
                            <p>Placed on {formatDateTime(order.order_time)}</p>
                          </div>
                          <div className="order-badges">
                            <span className="status-badge">{normalizeLabel(order.status, 'pending')}</span>
                            <span className="status-badge secondary">{normalizeLabel(order.payment_status, 'payment pending')}</span>
                          </div>
                        </div>
                        <div className="order-summary-grid">
                          <div>
                            <span>Total</span>
                            <strong>{formatCurrency(order.total_amount)}</strong>
                          </div>
                          <div>
                            <span>ETA</span>
                            <strong>{formatDateTime(order.estimated_delivery_time)}</strong>
                          </div>
                          <div>
                            <span>Delivery</span>
                            <strong>{normalizeLabel(order.delivery_status, 'unassigned')}</strong>
                          </div>
                          <div>
                            <span>Payment Method</span>
                            <strong>{order.payment_method ? order.payment_method.toUpperCase() : 'Not selected'}</strong>
                          </div>
                        </div>
                        <div className="order-items">
                          {order.items.map(item => (
                            <div className="order-item-row" key={`${order.order_id}-${item.item_id}`}>
                              <div>{item.item_name} x {item.quantity}</div>
                              <div>{formatCurrency(item.subtotal)}</div>
                            </div>
                          ))}
                        </div>
                        <div className="order-footer-meta">
                          <span>Delivery partner: {order.delivery_partner || 'Not assigned yet'}</span>
                          <button className="secondary-action" onClick={() => reorderItems(order)}>Reorder Items</button>
                        </div>

                        {paymentPending ? (
                          <div className="order-action-block">
                            <div className="block-heading">
                              <strong>Complete payment</strong>
                              <span>Select a payment method to confirm this order.</span>
                            </div>
                            <div className="payment-controls">
                              <select
                                value={paymentChoice[order.order_id] || 'upi'}
                                onChange={(event) => setPaymentChoice(current => ({ ...current, [order.order_id]: event.target.value }))}
                              >
                                {paymentMethods.map(method => (
                                  <option key={method} value={method}>{method.toUpperCase()}</option>
                                ))}
                              </select>
                              <button
                                className="primary-action"
                                onClick={() => payForOrder(order.order_id)}
                                disabled={busyAction === `pay-${order.order_id}`}
                              >
                                {busyAction === `pay-${order.order_id}` ? 'Processing…' : 'Make Payment'}
                              </button>
                            </div>
                          </div>
                        ) : null}

                        {order.status === 'delivered' ? (
                          <div className="order-action-block ratings-block">
                            <div className="ratings-head">
                              <strong>{hasExistingRatings ? 'Update ratings for this order' : 'Rate your delivered items'}</strong>
                              <span>Share ratings and optional reviews for each item.</span>
                            </div>
                            {order.items.map(item => {
                              const existing = order.ratings.find(rating => rating.item_id === item.item_id);
                              const key = `${order.order_id}:${item.item_id}`;
                              const ratingValue = draftRatings[key] ?? existing?.rating_value ?? 0;
                              const reviewValue = draftReviews[key] ?? existing?.review_text ?? '';
                              return (
                                <div className="rating-card" key={`rating-${order.order_id}-${item.item_id}`}>
                                  <label className="rating-line">
                                    <span>{item.item_name}</span>
                                    <select
                                      value={ratingValue}
                                      onChange={(event) =>
                                        setDraftRatings(current => ({
                                          ...current,
                                          [key]: Number(event.target.value)
                                        }))
                                      }
                                    >
                                      <option value={0}>Select rating</option>
                                      <option value={1}>1</option>
                                      <option value={2}>2</option>
                                      <option value={3}>3</option>
                                      <option value={4}>4</option>
                                      <option value={5}>5</option>
                                    </select>
                                  </label>
                                  <textarea
                                    value={reviewValue}
                                    onChange={(event) =>
                                      setDraftReviews(current => ({
                                        ...current,
                                        [key]: event.target.value
                                      }))
                                    }
                                    placeholder="Optional review"
                                    rows={3}
                                  />
                                </div>
                              );
                            })}
                            <button
                              className="secondary-action"
                              onClick={() => submitRatings(order)}
                              disabled={busyAction === `rate-${order.order_id}`}
                            >
                              {busyAction === `rate-${order.order_id}` ? 'Saving…' : 'Submit Ratings'}
                            </button>
                          </div>
                        ) : null}
                      </article>
                    );
                  }) : (
                    <div className="empty-state">No orders in this view yet.</div>
                  )}
                </div>
              </section>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

export default CustomerPortal;
