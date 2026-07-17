import "./SearchHeader.css";

const SearchHeader = ({ filters, setFilters, fetchRecipes }) => {
  const handleInputChange = (e) => {
    setFilters({ ...filters, query: e.target.value });
  };

  return (
    <div className="search">
      <div className="search-overlay">
        <h1 className="search-title">Recipes</h1>

        <form className="search-form" onSubmit={(e) => e.preventDefault()}>
          <input
            type="text"
            placeholder="Search recipes"
            value={filters.query}
            onChange={handleInputChange}
          />
        </form>

        <button className="search-full-button" onClick={fetchRecipes}>
          🔍 Search
        </button>
      </div>
    </div>
  );
};

export default SearchHeader;
