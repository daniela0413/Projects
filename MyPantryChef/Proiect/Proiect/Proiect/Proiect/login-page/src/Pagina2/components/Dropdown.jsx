const Dropdown = ({ label, value, onChange, options }) => {
  return (
    <div style={{ margin: '10px' }}>
      <label style={{ fontSize: '18px', display: 'block', marginBottom: '5px' }}>{label}</label>
      <select
        value={value}
        onChange={onChange}
        style={{ padding: '8px', width: '200px', borderRadius: '5px', border: '1px solid #ccc' }}
      >
        <option value="">Nothing selected</option>
        {options.map((option, index) => (
          <option key={index} value={option}>{option}</option>
        ))}
      </select>
    </div>
  );
};

export default Dropdown;
