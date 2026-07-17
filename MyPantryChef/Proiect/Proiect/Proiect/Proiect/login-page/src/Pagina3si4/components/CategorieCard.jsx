import './CategorieCard.css';

const CategorieCard = ({ name, image, onClick }) => {
  return (
    <div className="categorie-card" onClick={onClick}>
      <img src={image} alt={name} />
      <h3>{name}</h3>
    </div>
  );
};

export default CategorieCard;
