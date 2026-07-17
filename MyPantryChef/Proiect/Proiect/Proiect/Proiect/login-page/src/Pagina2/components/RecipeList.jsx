import RecipeCard from "./RecipeCard";
import "./RecipeList.css";
 
const RecipeList = ({ recipes }) => {
  return (
    <div className="recipe-list">
      {recipes.length > 0 ? (
        <div className="recipe-grid">
          {recipes.map((recipe) => (
            <RecipeCard
              key={recipe.id}
              id={recipe.id}
              title={recipe.title}
              image={recipe.imageUrl}
              type={recipe.mealType}
              time={recipe.cookingTime}
            />
          ))}
        </div>
      ) : (
        <p style={{ textAlign: "center", marginTop: "40px", fontSize: "1.2rem" }}>
          No recipes found for this search.
        </p>
      )}
    </div>
  );
};
 
export default RecipeList;