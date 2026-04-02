# FlameDesk Frontend - React Application

This is the React frontend for FlameDesk, a Cloud Kitchen OS. The application has been converted from plain HTML/CSS/JavaScript to a modern React application using Vite.

## Features

- **Login Page**: Authentication interface with animated background
- **Dashboard**: Main application interface with sidebar navigation
- **Responsive Design**: Mobile-friendly layout
- **React Router**: Client-side routing between pages

## Getting Started

### Prerequisites

- Node.js (v16 or higher)
- npm or yarn

### Installation

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm run dev
   ```

4. Open your browser and visit `http://localhost:5173`

### Build for Production

```bash
npm run build
```

## Project Structure

```
frontend/
├── public/
│   ├── index.html
│   └── favicon.svg
├── src/
│   ├── components/
│   ├── App.tsx          # Main app component with routing
│   ├── Login.tsx        # Login page component
│   ├── Login.css        # Login page styles
│   ├── Dashboard.tsx    # Dashboard component
│   ├── Dashboard.css    # Dashboard styles
│   ├── App.css          # Global styles
│   ├── index.css        # Base styles with fonts
│   └── main.tsx         # App entry point
├── package.json
└── vite.config.ts
```

## Authentication

The app uses sessionStorage for simple authentication:
- Username: `admin`
- Password: `admin123`

## Technologies Used

- **React 19**: Latest React with modern hooks
- **TypeScript**: Type-safe JavaScript
- **Vite**: Fast build tool and dev server
- **React Router**: Client-side routing
- **CSS Variables**: Modern CSS with custom properties
- **Google Fonts**: Syne and DM Sans font families
export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...

      // Remove tseslint.configs.recommended and replace with this
      tseslint.configs.recommendedTypeChecked,
      // Alternatively, use this for stricter rules
      tseslint.configs.strictTypeChecked,
      // Optionally, add this for stylistic rules
      tseslint.configs.stylisticTypeChecked,

      // Other configs...
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```

You can also install [eslint-plugin-react-x](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-x) and [eslint-plugin-react-dom](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-dom) for React-specific lint rules:

```js
// eslint.config.js
import reactX from 'eslint-plugin-react-x'
import reactDom from 'eslint-plugin-react-dom'

export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...
      // Enable lint rules for React
      reactX.configs['recommended-typescript'],
      // Enable lint rules for React DOM
      reactDom.configs.recommended,
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```
