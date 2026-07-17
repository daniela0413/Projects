import React, { useState } from 'react';
import axios from 'axios';

const CommentForm = ({ recipeId, onCommentAdded }) => {
  const [description, setDescription] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();

    const userId = localStorage.getItem("userId");

    if (!userId) {
      alert("You are not logged in!");
      return;
    }

    try {
      await axios.post(`https://localhost:7080/api/Recipe/${recipeId}/comment`, {
        id_User: parseInt(userId),
        description: description
      });

      setDescription('');
      if (onCommentAdded) onCommentAdded();
    } catch (err) {
      console.error('Error sending comment:', err);
      alert("The comment could not be sent.");
    }
  };

  return (
    <form onSubmit={handleSubmit} style={{ marginTop: '1rem' }}>
      <textarea
        placeholder="Write a comment..."
        value={description}
        onChange={(e) => setDescription(e.target.value)}
        rows={3}
        style={{ width: '100%', padding: '8px' }}
        required
      />
      <button type="submit" style={{
  marginTop: '0.5rem',
  backgroundColor: '#d16b86',
  color: 'white',
  border: 'none',
  padding: '8px 16px',
  borderRadius: '5px',
  cursor: 'pointer',
  fontWeight: 'bold'
}}>
  Send comment
</button>
    </form>
  );
};

export default CommentForm;
