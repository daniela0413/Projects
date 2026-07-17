import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import LoginForm from './Components/LoginForm/LoginForm';
import RegisterForm from './Components/RegisterForm/RegisterForm';
import ForgotPassword from './Components/LoginForm/ForgotPassword';
import PaginaAdmin from './Components/AdminForm/PaginaAdmin';
import AppPagina2 from './Pagina2/AppPagina2';
import IngredientSelectorPage from './Pagina3si4/IngredientSelectorPage';
import IngredientPage from './Pagina3si4/components/IngredientPage';
import RecipeDetail from './Pagina2/components/RecipeDetail';
 
import './App.css';
 
function App() {
  return (
    <div className="App">
      <Router>
        <Routes>
          {/* Autentificare */}
          <Route path="/" element={<LoginForm />} />
          <Route path="/register" element={<RegisterForm />} />
          <Route path="/forgot-password" element={<ForgotPassword />} />
          <Route path="/admin" element={<PaginaAdmin />} />
 
          {/* Pagina cu retete si detalii reteta */}
          <Route path="/retete" element={<AppPagina2 />} />
          <Route path="/recipe/:id" element={<RecipeDetail />} />
          <Route path="/recipe-detail/:id" element={<RecipeDetail />} />
 
          {/* Ingrediente si selectie */}
          <Route path="/select-ingredients" element={<IngredientSelectorPage />} />
          <Route path="/ingredients/:id" element={<IngredientPage />} />
        </Routes>
      </Router>
    </div>
  );
}
 
export default App;
 
 