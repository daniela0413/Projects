import './RecipeCard.css';
import { Link } from 'react-router-dom';
 
const RecipeCard = ({ id, title, image, type, time }) => {
  return (
    <Link to={`/recipe/${id}`} className="recipe-card-link">
      <div className="recipe-card">
        <img src={image} alt={title} className="recipe-img" />
        <div className="recipe-content">
          <h3 className="recipe-title">{title}</h3>
          <p className="recipe-tags">
            <span className="tag">{type}</span>
            <span className="tag">{time} min</span>
          </p>
        </div>
      </div>
    </Link>
  );
};
 
export default RecipeCard;