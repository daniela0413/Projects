import './Ingredient.css';

const Ingredient = ({ title, image }) => {
  return (
    <div className="ingredient-card">
      <img src={image} alt={title} />
      <h3>{title}</h3>
    </div>
  );
};

export default Ingredient;
