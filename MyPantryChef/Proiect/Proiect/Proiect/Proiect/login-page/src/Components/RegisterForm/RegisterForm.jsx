import './RegisterForm.css';
import React, { useState } from 'react';
import { FaEye, FaEyeSlash, FaUser, FaLock, FaEnvelope } from "react-icons/fa";

function RegisterForm() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [email, setEmail] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [passwordHovered, setPasswordHovered] = useState(false);

  function isValidPassword(password) {
    const lengthValid = password.length >= 8 && password.length <= 32;
    const hasUpper = /[A-Z]/.test(password);
    const hasLower = /[a-z]/.test(password);
    const hasNumber = /[0-9]/.test(password);
    const hasSymbol = /[^A-Za-z0-9]/.test(password);
    return lengthValid && hasUpper && hasLower && hasNumber && hasSymbol;
  }

  async function handleRegister(e) {
    e.preventDefault();

    if (!isValidPassword(password)) {
      alert("Password must be 8–32 characters long and include uppercase, lowercase, number, and symbol.");
      return;
    }

    try {
      const response = await fetch('https://localhost:7080/api/Auth/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password, email }),
      });

      if (response.ok) {
        const data = await response.json();
        alert('Registered successfully!');
        window.location.href = '/';
      } else {
        const errorText = await response.text();  
        console.error("Server error response:", errorText);
        alert('Registration failed: ' + errorText);
      }
    } catch (error) {
      console.error('Register error:', error);
      alert('Something went wrong.');
    }
  }

  return (
    <div className="register-background">
      <div className="wrapper">
        <form onSubmit={handleRegister}>
          <h1>Register</h1>

          <div className="input-box">
            <FaUser className="icon-left" />
            <input
              type="text"
              placeholder="Username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
            />
          </div>

          <div className="input-box">
            <FaEnvelope className="icon-left" />
            <input
              type="email"
              placeholder="Email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>

          <div className="input-box-with-tooltip">
            <div
              className="input-box"
              onMouseEnter={() => setPasswordHovered(true)}
              onMouseLeave={() => setPasswordHovered(false)}
            >
              <FaLock className="icon-left" />
              <input
                type={showPassword ? "text" : "password"}
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
              <span
                className="icon-eye"
                title={showPassword ? "Hide password" : "Show password"}
                onClick={() => setShowPassword(!showPassword)}
              >
                {showPassword ? <FaEyeSlash /> : <FaEye />}
              </span>
            </div>

            {passwordHovered && (
              <div className="password-tooltip">
                <p>Password must contain:</p>
                <ul>
                  <li className={password.length >= 8 && password.length <= 32 ? 'valid' : 'invalid'}>8–32 characters</li>
                  <li className={/[A-Z]/.test(password) ? 'valid' : 'invalid'}>Uppercase letter</li>
                  <li className={/[a-z]/.test(password) ? 'valid' : 'invalid'}>Lowercase letter</li>
                  <li className={/[0-9]/.test(password) ? 'valid' : 'invalid'}>Number</li>
                  <li className={/[^A-Za-z0-9]/.test(password) ? 'valid' : 'invalid'}>Symbol (!@#$...)</li>
                </ul>
              </div>
            )}
          </div>

          <button type="submit">Register</button>
          <div className="register-link">
            <p>Already have an account? <a href="/">Login</a></p>
          </div>
        </form>
      </div>
    </div>
  );
}

export default RegisterForm;
