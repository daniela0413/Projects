import './RecipeCard.css';
import { useNavigate } from 'react-router-dom';

const RecipeCard = ({ id, title, image, type, time, ingredients = [], onDelete }) => {
  const navigate = useNavigate();

  
  console.log(" RecipeCard props:", { id, title, type, time });

  const handleViewDetails = () => {
    navigate(`/recipe/${id}`);
  };

  return (
    <div className="recipe-card">
      <img src={image} alt={title} className="recipe-img" />
      <div className="recipe-content">
        <h3 className="recipe-title">{title}</h3>

        <p className="recipe-tags">
          <span className="tag">{type || "No type"}</span>
          <span className="tag">{time} min</span>
        </p>

        {ingredients.length > 0 && (
          <p><strong>Ingredients:</strong> {ingredients.join(', ')}</p>
        )}

        {onDelete && (
          <button className="remove-recipe-btn" onClick={onDelete}>Șterge</button>
        )}

         <button
        className="details-btn"
        onClick={handleViewDetails}
      >
        See details
      </button>

      </div>
    </div>
  );
};

export default RecipeCard;
