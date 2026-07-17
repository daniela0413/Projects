import React, { useEffect, useState } from 'react';
import axios from 'axios';
import CategorieCard from './components/CategorieCard';
import './IngredientSelectorPage.css';
import { useNavigate } from 'react-router-dom';

const IngredientSelectorPage = () => {
  const [categories, setCategories] = useState([]);
  const navigate = useNavigate();

  useEffect(() => {
    axios
      .get("https://localhost:7080/api/Categories")
      .then((res) => {
        const unique = Array.from(new Map(res.data.map(cat => [cat.id, cat])).values());
        setCategories(unique);
      })
      .catch((err) => console.error("Error loading categories:", err));
  }, []);

  return (
    <div className="page-ingredient-selector">
      
      {/* Buton Home  */}
      <div className="home-button-container" onClick={() => navigate("/retete")}>
        <span className="home-button-emoji">🏠</span>
      </div>

      <div className="app-container">
        <h1 className="title">Create the perfect recipe</h1>

        {categories.length === 0 ? (
          <p style={{ textAlign: "center" }}>No categories available.</p>
        ) : (
          <div className="categories-grid-wrapper">
            <div className="categories-grid">
              {categories.map((cat) => {
                const imageUrl = cat.imageUrl || '/placeholder.png'; 
                return (
                  <CategorieCard
                    key={cat.id}
                    name={cat.name}
                    image={imageUrl}
                    onClick={() => navigate(`/ingredients/${cat.id}`)}
                  />
                );
              })}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default IngredientSelectorPage;
