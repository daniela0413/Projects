import axios from "axios";
import "./PaginaAdmin.css";
import React, { useEffect, useRef, useState } from "react";

 
const PaginaAdmin = () => {
  const [categories, setCategories] = useState([]);
  const [ingredients, setIngredients] = useState([]);
  const [recipes, setRecipes] = useState([]);
  const [groupedIngredients, setGroupedIngredients] = useState({});
  const [expandedCategories, setExpandedCategories] = useState({});
  const [expandedCategoryList, setExpandedCategoryList] = useState(false);
  const [expandedMealTypes, setExpandedMealTypes] = useState({});
  const [mealTypeOptions, setMealTypeOptions] = useState([]);
  const [quickEasyOptions, setQuickEasyOptions] = useState([]);
  const [allergenOptions, setAllergenOptions] = useState([]);
  const recipeFormRef = useRef(null);

 
  const [categoryForm, setCategoryForm] = useState({ name: "", imageUrl: "" });
  const [ingredientForm, setIngredientForm] = useState({ name: "", categoryId: "" });
  const [recipeForm, setRecipeForm] = useState({
    id: null,
    title: "",
    description: "",
    instruction: "",
    imageUrl: "",
    mealType: "",
    cookingTime: 0,
    quickEasy: "",
    allergens: ""
  });
  const [selectedIngredients, setSelectedIngredients] = useState([]);
 
  const fetchDropdownOptions = async () => {
  try {
    const [mealTypes, quickEasy, allergens] = await Promise.all([
      axios.get("https://localhost:7080/api/FilterOptions/mealtypes"),
      axios.get("https://localhost:7080/api/FilterOptions/quickeasy"),
      axios.get("https://localhost:7080/api/FilterOptions/allergens")
    ]);
    setMealTypeOptions(mealTypes.data);
    setQuickEasyOptions(quickEasy.data);
    setAllergenOptions(allergens.data);
  } catch (error) {
    console.error("Error loading dropdowns:", error);
  }
};
 
 
 
 
  useEffect(() => {
  fetchCategories();
  fetchIngredients();
  fetchRecipes();
  fetchDropdownOptions(); 
}, []);
 
 
  const fetchCategories = async () => {
    const res = await axios.get("https://localhost:7080/api/Categories");
    setCategories(res.data);
  };
 
  const fetchIngredients = async () => {
    const res = await axios.get("https://localhost:7080/api/Ingredients");
    setIngredients(res.data);
    const grouped = {};
    res.data.forEach(ing => {
      if (!grouped[ing.categoryId]) grouped[ing.categoryId] = [];
      grouped[ing.categoryId].push(ing);
    });
    setGroupedIngredients(grouped);
  };
 
  const fetchRecipes = async () => {
    const res = await axios.get("https://localhost:7080/api/Recipe");
    setRecipes(res.data);
  };
 
  const handleCategorySubmit = async (e) => {
  e.preventDefault();

  try {
    await axios.post("https://localhost:7080/api/Categories/create", categoryForm);
    alert("Category added!");
    setCategoryForm({ name: "", imageUrl: "" });  
    fetchCategories();
  } catch (error) {
    if (error.response && error.response.status === 400) {
      alert("⚠️ " + error.response.data);
    } else {
      alert("❌ An error occurred while adding the category.");
      console.error(error);
    }
  }
};
 
 
  const handleIngredientSubmit = async (e) => {
  e.preventDefault();
  try {
    await axios.post("https://localhost:7080/api/Ingredients/create", {
      name: ingredientForm.name.trim(),
      categoryId: parseInt(ingredientForm.categoryId)
    });

    alert("Ingredient added!");
    setIngredientForm({ name: "", categoryId: "" });
    fetchIngredients();
  } catch (error) {
    if (error.response && error.response.status === 400) {
      const errorMessage = error.response.data.message || "An error occurred.";
      alert("⚠️ " + errorMessage);
    } else {
      alert("❌ An unexpected error occurred.");
      console.error(error);
    }
  }
};
 
  const handleRecipeSubmit = async (e) => {
  e.preventDefault();
 if (
    !recipeForm.title.trim() ||
    !recipeForm.description.trim() ||
    !recipeForm.instruction.trim() ||
    !recipeForm.imageUrl.trim() ||
    !recipeForm.mealType ||
    recipeForm.cookingTime <= 0 ||
    (recipeForm.quickEasy.length === 0) ||
    (recipeForm.allergens.length === 0) ||
    selectedIngredients.length === 0
  ) {
    alert("⚠️ Please complete all fields correctly.");
    return;
  }
   const urlRegex = /^(https?:\/\/.*\.(?:png|jpg|jpeg|webp|gif))$/i;
  if (!urlRegex.test(recipeForm.imageUrl.trim())) {
    alert("⚠️ Please enter a valid image URL (ending in .jpg, .png, etc.)");
    return;
  }
  const payload = {
    title: recipeForm.title,
    description: recipeForm.description,
    instruction: recipeForm.instruction,
    imageUrl: recipeForm.imageUrl,
    mealType: recipeForm.mealType,
    cookingTime: parseInt(recipeForm.cookingTime),
    quickEasy: (recipeForm.quickEasy || []).join(', '),
    allergens: (recipeForm.allergens || []).join(', '),
    ingredients: selectedIngredients.map(id => ({ ingredientId: id }))
  };
 
  try {
    if (recipeForm.id) {
      await axios.put(`https://localhost:7080/api/Recipe/${recipeForm.id}`, payload);
      alert("Recipe updated!");
    } else {
      await axios.post("https://localhost:7080/api/Recipe/create", payload);
      alert("Recipe added!");
    }
 
    // Reset formular
    setRecipeForm({
      id: null,
      title: "",
      description: "",
      instruction: "",
      imageUrl: "",
      mealType: "",
      cookingTime: 0,
      quickEasy: [],
      allergens: []
    });
    setSelectedIngredients([]);
    fetchRecipes();
  } catch (error) {
    console.error("Error saving recipe:", error);
     if (error.response && error.response.status === 400 && error.response.data.message) {
    alert("⚠️ " + error.response.data.message);
  } else {
    alert("Something went wrong.");
  }
  }
};
 
 
  const handleDeleteCategory = async (id) => {
    await axios.delete(`https://localhost:7080/api/Categories/${id}`);
    alert("Category deleted!");
    fetchCategories();
  };
 
  const handleDeleteIngredient = async (id) => {
    await axios.delete(`https://localhost:7080/api/Ingredients/${id}`);
    alert("Ingredient deleted!");
    fetchIngredients();
  };
 
  const handleDeleteRecipe = async (id) => {
    await axios.delete(`https://localhost:7080/api/Recipe/${id}`);
    alert("Recipe deleted!");
    fetchRecipes();
  };
 
  const handleEditRecipe = (recipe) => {
  setRecipeForm({
    ...recipe,
    quickEasy: recipe.quickEasy ? recipe.quickEasy.split(',').map(s => s.trim()) : [],
    allergens: recipe.allergens ? recipe.allergens.split(',').map(s => s.trim()) : []
  });
 
  setSelectedIngredients(recipe.ingredients?.map(i => i.ingredientId) || []);
   if (recipeFormRef.current) {
    recipeFormRef.current.scrollIntoView({ behavior: "smooth" });
  }
};
 
 
  const toggleCategory = (catId) => {
    setExpandedCategories(prev => ({ ...prev, [catId]: !prev[catId] }));
  };
 
  const toggleCategoryList = () => {
    setExpandedCategoryList(prev => !prev);
  };
 
  const toggleMealType = (type) => {
    setExpandedMealTypes(prev => ({ ...prev, [type]: !prev[type] }));
  };
 
  const handleIngredientCheck = (id) => {
    setSelectedIngredients(prev =>
      prev.includes(id) ? prev.filter(i => i !== id) : [...prev, id]
    );
  };
 
  const mealTypeGroups = recipes.reduce((acc, recipe) => {
    const type = recipe.mealType || "Other";
    if (!acc[type]) acc[type] = [];
    acc[type].push(recipe);
    return acc;
  }, {});
 
  return (
    <div className="admin-container">
      <h2>👩‍🍳 Admin Panel</h2>
 
      {/* Add Category */}
      <section>
        <h3>Add Category</h3>
        <form onSubmit={handleCategorySubmit}>
          <input name="name" placeholder="Category name" value={categoryForm.name} onChange={(e) => setCategoryForm({ ...categoryForm, name: e.target.value })} required />
          <input name="imageUrl" placeholder="Image URL" value={categoryForm.imageUrl} onChange={(e) => setCategoryForm({ ...categoryForm, imageUrl: e.target.value })} required/>
 
          <button type="submit">➕ Add category</button>
        </form>
        <div className="accordion-list">
          <div className="accordion-item">
            <div className="accordion-header" onClick={toggleCategoryList}>
              <span>📁 Existing Categories</span>
              <span>{expandedCategoryList ? "▲" : "▼"}</span>
            </div>
            {expandedCategoryList && (
              <ul className="compact-list">
                {categories.map(cat => (
                  <li key={cat.id}>
                    <span>{cat.name}</span>
                    <button className="delete-button small" onClick={() => handleDeleteCategory(cat.id)}>🗑️</button>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>
      </section>
 
      {/* Add Ingredient */}
      <section>
        <h3>Add Ingredient</h3>
        <form onSubmit={handleIngredientSubmit}>
          <input name="name" placeholder="Ingredient name" value={ingredientForm.name} onChange={(e) => setIngredientForm({ ...ingredientForm, name: e.target.value })} required />
          <select name="categoryId" value={ingredientForm.categoryId} onChange={(e) => setIngredientForm({ ...ingredientForm, categoryId: e.target.value })} required>
            <option value="">Select category</option>
            {categories.map(cat => (
              <option key={cat.id} value={cat.id}>{cat.name}</option>
            ))}
          </select>
          <button type="submit">➕ Add ingredient</button>
        </form>
 
        <div className="accordion-list">
          {categories.map(cat => (
            <div key={cat.id} className="accordion-item">
              <div className="accordion-header" onClick={() => toggleCategory(cat.id)}>
                <span>📂 {cat.name}</span>
                <span>{expandedCategories[cat.id] ? "▲" : "▼"}</span>
              </div>
              {expandedCategories[cat.id] && (
                <ul className="compact-list">
                  {(groupedIngredients[cat.id] || []).map(ing => (
                    <li key={ing.id}>
                      <span>{ing.name}</span>
                      <button className="delete-button small" onClick={() => handleDeleteIngredient(ing.id)}>🗑️</button>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          ))}
        </div>
      </section>
 
      {/* Add/Edit Recipe */}
      <section ref={recipeFormRef}>
        <h3>{recipeForm.id ? "✏️ Edit Recipe" : "📝 Add Recipe"}</h3>
        <form onSubmit={handleRecipeSubmit}>
          <label>Title</label>
<input name="title" placeholder="Title" value={recipeForm.title} onChange={(e) => setRecipeForm({ ...recipeForm, title: e.target.value })} required />
 
<label>Description</label>
<textarea name="description" placeholder="Description" value={recipeForm.description} onChange={(e) => setRecipeForm({ ...recipeForm, description: e.target.value })} />
 
<label>Instructions</label>
<textarea name="instruction" placeholder="Instructions" value={recipeForm.instruction} onChange={(e) => setRecipeForm({ ...recipeForm, instruction: e.target.value })} />
 
<label>Image URL</label>
<input name="imageUrl" placeholder="Image URL" value={recipeForm.imageUrl} onChange={(e) => setRecipeForm({ ...recipeForm, imageUrl: e.target.value })} />
 
<p className="form-group-title">Meal Type</p>
<div className="checkbox-group">
  {mealTypeOptions.map((type, idx) => (
    <label key={idx}>
      <input
        type="radio"
        name="mealType"
        value={type}
        checked={recipeForm.mealType === type}
        onChange={() => setRecipeForm({ ...recipeForm, mealType: type })}
      />
      {type}
    </label>
  ))}
</div>
 
 
<label>Cooking Time (minutes)</label>
<input type="number" name="cookingTime" placeholder="e.g. 30" min="1" value={recipeForm.cookingTime} onChange={(e) => setRecipeForm({ ...recipeForm, cookingTime: e.target.value })} />
 
 
<p className="form-group-title">Quick & Easy</p>
<div className="checkbox-group">
  {quickEasyOptions.map((opt, idx) => (
    <label key={idx}>
      <input
        type="checkbox"
        checked={recipeForm.quickEasy?.includes(opt)}
        onChange={() => {
          const newSelection = recipeForm.quickEasy?.includes(opt)
            ? recipeForm.quickEasy.filter(item => item !== opt)
            : [...(recipeForm.quickEasy || []), opt];
          setRecipeForm({ ...recipeForm, quickEasy: newSelection });
        }}
      />
      {opt}
    </label>
  ))}
</div>
 
<p className="form-group-title">Allergens</p>
<div className="checkbox-group">
  {allergenOptions.map((allergen, idx) => (
    <label key={idx}>
      <input
        type="checkbox"
        checked={recipeForm.allergens?.includes(allergen)}
        onChange={() => {
          const newSelection = recipeForm.allergens?.includes(allergen)
            ? recipeForm.allergens.filter(a => a !== allergen)
            : [...(recipeForm.allergens || []), allergen];
          setRecipeForm({ ...recipeForm, allergens: newSelection });
        }}
      />
      {allergen}
    </label>
  ))}
</div>
 
          <h4>Ingredients:</h4>
          <div className="accordion-list">
            {categories.map(cat => (
              <div key={cat.id} className="accordion-item">
                <div className="accordion-header" onClick={() => toggleCategory(cat.id)}>
                  <span>📂 {cat.name}</span>
                  <span>{expandedCategories[cat.id] ? "▲" : "▼"}</span>
                </div>
                {expandedCategories[cat.id] && (
                  <ul className="compact-list">
                    {(groupedIngredients[cat.id] || []).map(ing => (
                      <li key={ing.id}>
                        <label>
                          <input type="checkbox" checked={selectedIngredients.includes(ing.id)} onChange={() => handleIngredientCheck(ing.id)} /> {ing.name}
                        </label>
                      </li>
                    ))}
                  </ul>
                )}
              </div>
            ))}
          </div>
 
          <button type="submit">🍲 {recipeForm.id ? "Save changes" : "Add recipe"}</button>
        </form>
      </section>
 
      {/* Existing Recipes grouped by Meal Type */}
      <section>
        <h3>📋 Existing Recipes</h3>
        <div className="accordion-list">
          {Object.entries(mealTypeGroups).map(([type, recs]) => (
            <div key={type} className="accordion-item">
              <div className="accordion-header" onClick={() => toggleMealType(type)}>
                <span>🍽 {type}</span>
                <span>{expandedMealTypes[type] ? "▲" : "▼"}</span>
              </div>
              {expandedMealTypes[type] && (
                <ul className="compact-list">
                  {recs.map(rec => (
                    <li key={rec.id} className="recipe-item">
                      <span>{rec.title}</span>
                      <div className="recipe-buttons">
                        <button className="edit-button small" onClick={() => handleEditRecipe(rec)}>✏️</button>
                        <button className="delete-button small" onClick={() => handleDeleteRecipe(rec.id)}>🗑️</button>
                      </div>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          ))}
        </div>
      </section>
    </div>
  );
};
 
export default PaginaAdmin;