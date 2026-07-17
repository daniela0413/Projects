import { useEffect, useRef, useState } from "react";
import Cart from "../Cart";
import axios from "axios";
import "../IngredientSelectorPage.css";
import { useParams, useNavigate } from "react-router-dom";
import RecipeCard from "../../Pagina3si4/components/RecipeCard";

const IngredientPage = () => {
  const { id } = useParams();
  const navigate = useNavigate();

  const [ingredients, setIngredients] = useState([]);
  const [quantities, setQuantities] = useState({});
  const [selectedIngredients, setSelectedIngredients] = useState(() => {
    const saved = localStorage.getItem("selectedIngredients");
    return saved ? JSON.parse(saved) : [];
  });
  const [cartItems, setCartItems] = useState(() => {
    const saved = localStorage.getItem("cartItems");
    return saved ? JSON.parse(saved) : [];
  });

  useEffect(() => {
    localStorage.setItem("cartItems", JSON.stringify(cartItems));
  }, [cartItems]);

  const [showCart, setShowCart] = useState(false);
  const [generatedRecipes, setGeneratedRecipes] = useState(() => {
    const saved = localStorage.getItem("generatedRecipes");
    return saved ? JSON.parse(saved) : [];
  });

  const recipeRef = useRef(null);

  useEffect(() => {
    axios
      .get(`https://localhost:7080/api/Ingredients/by-category/${id}`)
      .then((res) => setIngredients(res.data))
      .catch((err) => console.error("Error loading ingredients: ", err));
  }, [id]);

  useEffect(() => {
    localStorage.setItem("selectedIngredients", JSON.stringify(selectedIngredients));
  }, [selectedIngredients]);

  useEffect(() => {
    localStorage.setItem("generatedRecipes", JSON.stringify(generatedRecipes));
  }, [generatedRecipes]);

  useEffect(() => {
    if (selectedIngredients.length === 0) {
      setGeneratedRecipes([]);
      localStorage.removeItem("generatedRecipes");
    }
  }, [selectedIngredients]);

  const handleQuantityChange = (ingredientId, value) => {
    setQuantities((prev) => ({ ...prev, [ingredientId]: value }));
  };

  const handleAdd = (ingredient) => {
    const rawQty = quantities[ingredient.id];
    const qty = parseInt(rawQty);

    if (!qty || isNaN(qty) || qty <= 0) return;

    setSelectedIngredients((prev) => {
      const existing = prev.find((i) => i.id === ingredient.id);
      if (existing) {
        return prev.map((i) =>
          i.id === ingredient.id ? { ...i, qty: i.qty + qty } : i
        );
      } else {
        return [...prev, { ...ingredient, qty }];
      }
    });

    setQuantities((prev) => ({ ...prev, [ingredient.id]: "" }));
  };

  const handleDelete = (index) => {
    const updated = [...selectedIngredients];
    updated.splice(index, 1);
    setSelectedIngredients(updated);
  };

  const handleCartAdd = (item) => {
    setCartItems((prev) => {
      const existing = prev.find((i) => i.id === item.id);
      if (existing) {
        return prev.map((i) =>
          i.id === item.id ? { ...i, qty: i.qty + item.qty } : i
        );
      } else {
        return [...prev, item];
      }
    });
    setSelectedIngredients((prev) => prev.filter((i) => i.id !== item.id));
  };

  const handleCartRemove = (index) => {
    const updated = [...cartItems];
    updated.splice(index, 1);
    setCartItems(updated);
  };

  const handleCheck = (index) => {
    const updated = [...cartItems];
    updated[index].checked = !updated[index].checked;
    setCartItems(updated);
  };

  const handleGenerateRecipe = async () => {
  try {
    const storedFilters = JSON.parse(localStorage.getItem("selectedFilters"));

    console.log("📦 Filters before generate:", storedFilters); // DEBUG

    const generatePayload = {
      ingredients: selectedIngredients.map(item => ({
        ingredientId: item.id,
        quantity: item.qty,
        userId: 0
      })),
      filters: storedFilters || {
        query: "",
        type: "",
        quickAndEasy: "",
        timeToMake: "",
        allergens: []
      }
    };

    const res = await axios.post("https://localhost:7080/api/Recipe/generate-with-filters", generatePayload, {
      headers: { "Content-Type": "application/json" }
    });

    if (!res.data || res.data.length === 0) {
      alert("No recipe found for selected ingredients.");
      setGeneratedRecipes([]);
      localStorage.removeItem("generatedRecipes");
      return;
    }

    setGeneratedRecipes(res.data);
    setTimeout(() => {
      recipeRef.current?.scrollIntoView({ behavior: "smooth" });
    }, 100);
  } catch (err) {
    console.error("Error in generate recipe:", err);
    alert("An error occurred while generating the recipe.");
  }
};
    

  const handleResetList = () => {
    setSelectedIngredients([]);
    localStorage.removeItem("selectedIngredients");
    setGeneratedRecipes([]);
    localStorage.removeItem("generatedRecipes");
  };

  return (
    <div className="page-ingredient-selector">
      {/*  MODIFICARE: div -> button pentru a evita zoom la click */}
      {/*  Buton Home – sus dreapta */}
<div
  className="home-button-container"
  onClick={() => navigate("/retete")}
  title="Go Home"
>
  <span className="home-button-emoji">🏠</span>
</div>

{/*  Cos cumparaturi */}
<div className="cart-icon-container" onClick={() => setShowCart((prev) => !prev)}>
  <span className="cart-icon-emoji">🛒</span>
  {cartItems.length > 0 && (
    <span className="cart-badge">{cartItems.length}</span>
  )}
</div>




      <h2 className="category-title">Ingredients</h2>

      <div className="ingredient-list">
        {ingredients.map((ingredient) => (
          <div key={ingredient.id} className="ingredient-card">
            <h3>{ingredient.name}</h3>
            <input
              type="number"
              min="0"
              value={quantities[ingredient.id] || ""}
              placeholder="Qty"
              onChange={(e) => handleQuantityChange(ingredient.id, e.target.value)}
            />
            <button onClick={() => handleAdd(ingredient)}>＋</button>
          </div>
        ))}
      </div>

      {selectedIngredients.length > 0 && (
        <div className="summary">
          <h3 className="summary-title">Selected ingredients</h3>
          <ul>
            {selectedIngredients.map((item, index) => (
              <li key={index} className="selected-item">
                <span>{item.name} - {item.qty} pcs</span>
                <button className="delete-btn" onClick={() => handleDelete(index)}>x</button>
                <button className="delete-btn" onClick={() => handleCartAdd(item)}>🛒</button>
              </li>
            ))}
          </ul>
        </div>
      )}

      {showCart && (
        <div className="shopping-cart-section">
          <Cart items={cartItems} onRemove={handleCartRemove} onCheck={handleCheck} />
        </div>
      )}

      <div className="actions">
        {selectedIngredients.length > 0 && (
          <>
            <button className="generate-btn" onClick={handleGenerateRecipe}>🧑‍🍳 Generate recipe</button>
            <button className="reset-btn" onClick={handleResetList}>🧹 Reset list</button>
          </>
        )}
        <button className="back-btn" onClick={() => navigate("/select-ingredients")}>🔙 Back to the categories</button>
      </div>

      {generatedRecipes.length > 0 && (
        <div className="generated-recipe-list" ref={recipeRef}>
          <h2 style={{
            backgroundColor: "#dbaec6",
            padding: "15px 25px",
            borderRadius: "15px",
            color: "white",
            width: "fit-content",
            margin: "30px auto",
            fontSize: "1.8rem"
          }}>
            🍽️ Generated Recipes
          </h2>

          <div className="recipe-grid">
            {generatedRecipes.map((recipe) => (
              <RecipeCard
                key={recipe.id}
                id={recipe.id}
                title={recipe.title}
                image={recipe.imageUrl}
                type={recipe.mealType}
                time={recipe.cookingTime}
                showBackButton={true}
              />
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default IngredientPage;
