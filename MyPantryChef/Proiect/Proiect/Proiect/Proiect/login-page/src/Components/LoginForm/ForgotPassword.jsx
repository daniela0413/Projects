import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import './LoginForm.css';

function ForgotPassword() {
  const [email, setEmail] = useState('');
  const [message, setMessage] = useState('');
  const [isError, setIsError] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();

    try {
      const response = await fetch('https://localhost:7080/api/Auth/forgot-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email })
      });

      const data = await response.json();

      if (response.ok) {
        setIsError(false);
        setMessage(data.message);
      } else {
        setIsError(true);
        setMessage(data.message || "An error occurred while sending the email.");
      }
    } catch (err) {
      setIsError(true);
      setMessage("An unexpected error occurred.");
    }
  }

  return (
    <div className="login-background">
      <div className="wrapper">
        <h1>Forgot Password</h1>

        <p className="info-box">
          ✉️ Enter your email address below and we'll send you your password.
        </p>

        <form onSubmit={handleSubmit}>
          <div className="input-box">
            <input
              type="email"
              placeholder="Your email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>

          <button type="submit">Send Email</button>
        </form>

        {message && (
          <p className={isError ? 'error-message' : 'success-message'}>
            {message}
          </p>
        )}

        <div className="register-link">
          <p><Link to="/">Back to login</Link></p>
        </div>
      </div>
    </div>
  );
}

export default ForgotPassword;
