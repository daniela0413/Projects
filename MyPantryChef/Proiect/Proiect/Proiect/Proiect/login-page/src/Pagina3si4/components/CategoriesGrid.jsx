import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import CategorieCard from './CategorieCard';
import axios from 'axios';
import './CategorieCard.css';

function CategoriesGrid() {
  const [categories, setCategories] = useState([]);
  const navigate = useNavigate();

  useEffect(() => {
    axios.get('http://localhost:7080/api/Categories')
      .then(res => {
        setCategories(res.data);
      })
      .catch(err => console.error("Error retrieving categories:", err));
  }, []);

  return (
    <>
      {/* HOME button fix in dreapta sus */}
      <div className="home-button-container" onClick={() => navigate("/retete")}>
        <span className="home-button-emoji">🏠</span>
      </div>

      <div className="categories-grid-wrapper">
        <div className="categories-grid">
          {categories.map((cat) => (
            <CategorieCard
              key={cat.id}
              name={cat.name}
              image={cat.imageUrl || '/placeholder.png'}
              onClick={() => navigate(`/ingredients/${cat.id}`)}
            />
          ))}
        </div>
      </div>
    </>
  );
}

export default CategoriesGrid;
