import React, { useState, useEffect } from 'react';
import axios from 'axios';

const StarRating = ({ recipeId, userId }) => {
  const [rating, setRating] = useState(0);
  const [hovered, setHovered] = useState(0);
  const [voteCount, setVoteCount] = useState(0); 

  useEffect(() => {
    const fetchRating = async () => {
      try {
        const response = await axios.get(`https://localhost:7080/api/Recipe/${recipeId}`);
        setRating(response.data.rating);
        setVoteCount(response.data.ratingCount); 
      } catch (err) {
        console.error("Failed to load recipe rating", err);
      }
    };
    fetchRating();
  }, [recipeId]);

  const handleRating = async (value) => {
    try {
      const payload = { userId: userId, value: value };
      const response = await axios.post(
        `https://localhost:7080/api/Recipe/${recipeId}/rate`,
        payload,
        { headers: { 'Content-Type': 'application/json' } }
      );
      setRating(response.data); 
      setVoteCount(prev => prev >= 1 ? prev : prev + 1); 
    } catch (err) {
      console.error('Rating failed', err);
    }
  };

  return (
    <div style={{ textAlign: 'center', margin: '1rem 0' }}>
      <div style={{ display: 'inline-block', position: 'relative' }}>
        {/* Stele gri (fundal) */}
        {[...Array(5)].map((_, i) => (
          <span key={i} style={{ fontSize: '2rem', color: 'lightgray' }}>★</span>
        ))}

        {/* Stele galbene (foreground) cu clip */}
        <div
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            width: `${(hovered || rating) / 5 * 100}%`,
            overflow: 'hidden',
            whiteSpace: 'nowrap',
            pointerEvents: 'none'
          }}
        >
          {[...Array(5)].map((_, i) => (
            <span key={i} style={{ fontSize: '2rem', color: 'gold' }}>★</span>
          ))}
        </div>

        <div style={{
          position: 'absolute',
          top: 0,
          left: 0,
          display: 'flex',
          width: '100%',
          height: '100%',
        }}>
          {[1, 2, 3, 4, 5].map((val) => (
            <span
              key={val}
              onClick={() => handleRating(val)}
              onMouseEnter={() => setHovered(val)}
              onMouseLeave={() => setHovered(0)}
              style={{
                flex: 1,
                cursor: 'pointer',
              }}
            />
          ))}
        </div>
      </div>

      <div style={{ fontSize: '0.9rem', marginTop: '4px', color: '#555' }}>
        {rating > 0 ? (
          <>
            Average rating: {rating.toFixed(1)}/5<br />
            <span style={{ fontSize: '0.8rem', color: '#999' }}>
              ({voteCount} vote{voteCount !== 1 ? 's' : ''})
            </span>
          </>
        ) : 'Click to rate'}
      </div>
    </div>
  );
};

export default StarRating;
