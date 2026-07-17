import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import axios from "axios";
import StarRating from "../../Pagina3si4/components/StarRating";
import CommentForm from "../../Pagina3si4/components/CommentForm";
import "./RecipeDetail.css";

const RecipeDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [recipe, setRecipe] = useState(null);

  const currentUserId = parseInt(localStorage.getItem("userId"));
  const currentUsername = localStorage.getItem("username");

  const [editComment, setEditComment] = useState(null);
  const [editText, setEditText] = useState("");

  const fetchRecipe = () => {
    axios
      .get(`https://localhost:7080/api/Recipe/${id}`)
      .then((res) => {
        setRecipe(res.data);
      })
      .catch((err) => console.error("Error loading recipe:", err));
  };

  const handleEdit = (comment) => {
    setEditComment(comment);
    setEditText(comment.description);
  };

  const submitEdit = async () => {
    try {
      await axios.put(`https://localhost:7080/api/Recipe/comment/${editComment.id}`, {
        id_User: currentUserId,
        description: editText
      });
      setEditComment(null);
      fetchRecipe();
    } catch (error) {
      console.error("Error editing comment:", error);
    }
  };

  const handleDelete = async (comment) => {
    if (!window.confirm("Are you sure you want to delete this comment?")) return;
    try {
      await axios.delete(`https://localhost:7080/api/Recipe/comment/${comment.id}`);
      fetchRecipe();
    } catch (error) {
      console.error("Error deleting comment:", error);
    }
  };

  useEffect(() => {
    fetchRecipe();
  }, [id]);

  if (!recipe) return <p>Loading...</p>;

  const getMealEmoji = (type) => {
    switch (type?.toLowerCase()) {
      case "breakfast": return "☀️";
      case "lunch": return "🍽️";
      case "dinner": return "🌙";
      case "snack": return "🍪";
      case "dessert": return "🍰";
      default: return "🔙";
    }
  };

  return (
    <div className="recipe-detail">
      <h1>{recipe.title}</h1>

      <img src={recipe.imageUrl} alt={recipe.title} />
      <p><strong>Cooking time:</strong> {recipe.cookingTime} minutes</p>
      <p><strong>Description:</strong> {recipe.description}</p>

      {/* stelele + ratingul mediu */}
      <StarRating recipeId={recipe.id} userId={currentUserId} />

      <p><strong>Instructions:</strong><br />
        {recipe.instructions.split('\\n').map((line, index) => (
          <span key={index}>
            {line}<br />
          </span>
        ))}
      </p>

      <h3>Ingredients:</h3>
      <ul>
        {recipe.ingredients?.map((ing) => (
          <li key={ing.id}>{ing.name}</li>
        ))}
      </ul>

      <div className="comment-section">
        <h3>Comments:</h3>
        {recipe.comments?.length > 0 ? (
          recipe.comments.map((comment, index) => (
            <div
              key={index}
              className="comment-item"
              style={{
                backgroundColor: "#feeef4",
                padding: "10px",
                marginBottom: "10px",
                borderRadius: "8px"
              }}
            >
<strong style={{ color: "crimson" }}>👤 {comment.username}</strong>
              <span style={{ marginLeft: "10px", color: "#555" }}>
                — {new Date(comment.date).toLocaleDateString()}
              </span>
              <p>{comment.description}</p>

              {comment.username === currentUsername && (
  <div style={{ display: 'flex', gap: '10px' }}>
    <button onClick={() => handleEdit(comment)} className="comment-button edit">📝Edit</button>
    <button onClick={() => handleDelete(comment)} className="comment-button delete">🗑️Delete</button>
  </div>
)}
            </div>
          ))
        ) : (
          <p>No comments yet.</p>
        )}

        {editComment && (
  <div style={{ marginTop: '1rem', padding: '1rem', border: '1px solid #ccc', backgroundColor: '#fbeff4', borderRadius: '10px' }}>
    <h4 style={{ marginBottom: '0.5rem', color: '#a174b3' }}>Edit your comment</h4>
    <textarea
      value={editText}
      onChange={(e) => setEditText(e.target.value)}
      rows={3}
      style={{ width: '100%', padding: '8px', borderRadius: '5px', border: '1px solid #ccc' }}
    />
    <div style={{ marginTop: '0.5rem', display: 'flex', gap: '10px' }}>
      <button onClick={submitEdit} className="comment-button save">Save</button>
      <button onClick={() => setEditComment(null)} className="comment-button cancel">Cancel</button>
    </div>
  </div>
)}


        <CommentForm
          recipeId={recipe.id}
          userId={currentUserId}
          onCommentAdded={fetchRecipe}
        />
      </div>

      <div style={{ textAlign: "center", marginTop: "30px" }}>
        <button
          onClick={() => navigate(-1)}
          style={{
            backgroundColor: "#cc99b2",
            color: "white",
            border: "none",
            padding: "10px 20px",
            borderRadius: "10px",
            fontSize: "16px",
            fontWeight: "bold",
            cursor: "pointer",
            boxShadow: "0 4px 10px rgba(0, 0, 0, 0.1)"
          }}
        >
          {getMealEmoji(recipe.mealType)} Back to generated recipes
        </button>
      </div>
    </div>
  );
};

export default RecipeDetail;
