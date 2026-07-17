import React, { useEffect } from 'react';
import Dropdown from './Dropdown';
import './FilterBar.css';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
 
const FilterBar = ({ filters, setFilters, onApplyFilters }) => {
  const [typeOptions, setTypeOptions] = React.useState([]);
  const [quickOptions, setQuickOptions] = React.useState([]);
  const [timeOptions, setTimeOptions] = React.useState([]);
  const [allergenOptions, setAllergenOptions] = React.useState([]);
 
  const navigate = useNavigate();
 
  useEffect(() => {
    axios.get('https://localhost:7080/api/FilterOptions/mealtypes')
      .then(res => setTypeOptions(res.data));
 
    axios.get('https://localhost:7080/api/FilterOptions/quickeasy')
      .then(res => setQuickOptions(res.data));
 
    axios.get('https://localhost:7080/api/FilterOptions/cookingtimes')
      .then(res => setTimeOptions(res.data));
 
    axios.get('https://localhost:7080/api/FilterOptions/allergens')
      .then(res => setAllergenOptions(res.data));
  }, []);
 
  const handleChange = (key) => (e) => {
  const value = e.target.value;
  if (setFilters) {
    if (key === 'allergens') {
      setFilters((prev) => ({ ...prev, [key]: value ? [value] : [] }));
    } else {
      setFilters((prev) => ({ ...prev, [key]: value }));
    }
  }
};
 
 const handleSubmit = () => {
  console.log('Submitted Filters:', filters);
  localStorage.setItem('selectedFilters', JSON.stringify(filters)); 
  navigate('/select-ingredients'); 
};
 
 const handleReset = () => {
  const resetFilters = {
    query: '',
    type: '',
    quickAndEasy: '',
    timeToMake: '',
    allergens: []
  };
 
  setFilters(resetFilters);
 
 
  setTimeout(() => {
      axios
        .get("https://localhost:7080/api/Recipe")
        .then((res) => {
          if (onApplyFilters) {
            onApplyFilters(res.data);
          }
        })
        .catch((err) => console.error("Error loading recipes:", err));
    }, 0);
  };
 
const handleApplyFilters = () => {
  if (onApplyFilters) {
    onApplyFilters();
  }
};

 
  return (
    <div className="filter-bar">
      <Dropdown
        label="Recipe Type"
        value={filters.type}
        onChange={handleChange('type')}
        options={typeOptions}
      />
      <Dropdown
        label="Quick & Easy"
        value={filters.quickAndEasy}
        onChange={handleChange('quickAndEasy')}
        options={quickOptions}
      />
      <Dropdown
        label="Time to Make"
        value={filters.timeToMake}
        onChange={handleChange('timeToMake')}
        options={timeOptions}
      />
      <Dropdown
        label="Allergens"
        value={filters.allergens.length > 0 ? filters.allergens[0] : ''}
        onChange={handleChange('allergens')}
        options={allergenOptions}
      />
 
      <div className="filter-buttons">
        <button onClick={handleSubmit}>Submit</button>
        <button onClick={handleApplyFilters} className="apply">Apply Filters</button>
        <button onClick={handleReset} className="reset">Reset</button>
      </div>
    </div>
  );
};
 
export default FilterBar;