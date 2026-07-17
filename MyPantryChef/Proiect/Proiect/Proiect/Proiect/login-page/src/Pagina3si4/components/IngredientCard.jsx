import React, { useState } from 'react';
import './IngredientCard.css';

const IngredientCard = ({ name, onAdd }) => {
  const [qty, setQty] = useState('');

  const handleClick = () => {
    if (qty && parseInt(qty) > 0) {
      onAdd(name, qty);
      setQty('');
    }
  };

  return (
    <div className="ingredient-card">
      <span>{name}</span>
      <input
        type="number"
        placeholder="Cant."
        min="1"
        value={qty}
        onChange={(e) => setQty(e.target.value)}
      />
      <button onClick={handleClick}>+</button>
    </div>
  );
};

export default IngredientCard;
