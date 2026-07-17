import React, { useState, useEffect } from 'react';
import axios from 'axios';
import SearchHeader from './components/SearchHeader';
import FilterBar from './components/FilterBar';
import RecipeList from './components/RecipeList';
import { useNavigate } from 'react-router-dom';

function AppPagina2() {
  const [recipes, setRecipes] = useState([]);
  const [filters, setFilters] = useState({
    query: '',
    type: '',
    quickAndEasy: '',
    timeToMake: '',
    allergens: []
  });
  const [searchTitle, setSearchTitle] = useState("All Recipes");
  const navigate = useNavigate();

  useEffect(() => {
    axios
      .get("https://localhost:7080/api/Recipe")
      .then((res) => {
        setRecipes(res.data);
        setSearchTitle("All Recipes");
      })
      .catch((err) => console.error("Error loading recipes:", err));
  }, []);

  const fetchFilteredRecipes = () => {
    axios
      .post("https://localhost:7080/api/Recipe/search-by-title", { query: filters.query })
      .then((res) => {
        setRecipes(res.data);
        if (filters.query && filters.query.trim() !== "") {
          setSearchTitle(`Search results for: ${filters.query}`);
        } else {
          setSearchTitle("All Recipes");
        }
      })
      .catch((err) => console.error("Error filtering recipes:", err));
  };

  const handleApplyFilters = async (recipesFromReset = null) => {
    if (recipesFromReset) {
      setRecipes(recipesFromReset);
      setSearchTitle("All Recipes");
      return;
    }

    const allEmpty = !filters.query && !filters.type && !filters.quickAndEasy && !filters.timeToMake && filters.allergens.length === 0;
    if (allEmpty) {
      axios
        .get("https://localhost:7080/api/Recipe")
        .then((res) => {
          setRecipes(res.data);
          setSearchTitle("All Recipes");
        })
        .catch((err) => console.error("Error loading recipes:", err));
      return;
    }

    try {
      const response = await axios.post("https://localhost:7080/api/Recipe/search", {
        query: filters.query || '',
        type: filters.type || '',
        quickAndEasy: filters.quickAndEasy || '',
        timeToMake: filters.timeToMake || '',
        allergens: filters.allergens || []
      });

      setRecipes(response.data);
      setSearchTitle("Filtered Recipes");
    } catch (error) {
      console.error("Error applying filters:", error.response?.data || error.message);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem("userId");
    localStorage.removeItem("username");
    localStorage.removeItem("role");
    localStorage.removeItem("rememberedUsername");
    navigate("/");
  };

  return (
    <div className="recipes-page">

      {/* Logout button */}
      <div style={{ display: "flex", justifyContent: "flex-end", padding: "10px" }}>
        <button
          onClick={handleLogout}
          style={{
            backgroundColor: "#dc3545",
            color: "white",
            padding: "8px 12px",
            border: "none",
            borderRadius: "5px",
            cursor: "pointer"
          }}
        >
          Logout
        </button>
      </div>

      <SearchHeader
        filters={filters}
        setFilters={setFilters}
        fetchRecipes={fetchFilteredRecipes}
      />

      <FilterBar
        filters={filters}
        setFilters={setFilters}
        fetchRecipes={fetchFilteredRecipes}
        onApplyFilters={handleApplyFilters}
      />

      <h1 style={{ textAlign: 'center', marginTop: '20px' }}>{searchTitle}</h1>

      <RecipeList recipes={recipes} />
    </div>
  );
}

export default AppPagina2;
