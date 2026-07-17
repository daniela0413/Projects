import './Cart.css';

const Cart = ({ items, onRemove, onCheck }) => {
  const handleSendCartEmail = async () => {
    const userId = localStorage.getItem("userId");

    if (!userId) {
      alert("You are not logged in. Please log in again.");
      return;
    }

    try {
      console.log("handleSendCartEmail triggered");

      const payload = {
        userId: parseInt(userId),
        items: items.map(item => ({
          ingredientId: item.id,
          quantity: item.qty
        }))
      };

      console.log("Payload to send:", payload);

      const response = await fetch("https://localhost:7080/api/cart/send-cart-summary", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload)
      });

      const message = await response.text();
      console.log("Response status:", response.status);
      console.log("Response OK:", response.ok);
      console.log("Message from backend:", message);

      alert(response.ok ? "Success: " + message : "Error: " + message);
    } catch (err) {
      console.error("Network or server error:", err);
      alert("A network error occurred or the server is unavailable.");
    }
  };

  return (
    <div className="cart-wrapper">
      <h3 className="cart-title">🛒 Shopping Cart</h3>
      {items.length === 0 ? (
        <p style={{ textAlign: "center", color: "#555" }}>No items in the cart.</p>
      ) : (
        items.map((item, index) => (
          <div key={index} className="cart-item">
            <input
              type="checkbox"
              className="cart-checkbox"
              checked={item.checked || false}
              onChange={() => onCheck(index)}
            />
            <span className={item.checked ? 'checked' : ''}>
              {item.name} – {item.qty} pcs
            </span>
            <button className="cart-delete-btn" onClick={() => onRemove(index)}>
              x
            </button>
          </div>
        ))
      )}

      {items.length > 0 && (
        <div className="cart-email-section">
          <button className="cart-email-btn" onClick={handleSendCartEmail}>
            📧 Send cart by email
          </button>
        </div>
      )}
    </div>
  );
};

export default Cart;
