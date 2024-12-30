# **MINIMAL REST API FRAMEWORK**

---

This project is a **minimal REST API framework** implemented in Python without any external dependencies. It provides a lightweight HTTP server and a simple routing mechanism to handle basic CRUD operations.

---

## 🌟 **FEATURES**

- 🚀 **Lightweight:** No external libraries required.
- 🔧 **Simple Routing:** Easy to define routes with `GET` and `POST` methods.
- 📄 **JSON Responses:** Automatically formats responses in JSON.
- 💡 **Customizable:** Add your own endpoints with minimal effort.
- 🌍 **Open Source:** Licensed under MIT for flexibility and reusability.

---

## 📦 **INSTALLATION**

### Clone the repository:

```bash
git clone https://github.com/YOUR_USERNAME/Minimal-Rest-Api-Framework.git
cd Minimal-Rest-Api-Framework
```

### Ensure you have Python 3 installed on your system.

### Run the server:

```bash
python minimal_rest_framework.py
```

---

## 🚦 **QUICK START**

The framework comes with a few pre-defined routes. Below is a summary of the available endpoints:

### `GET /`
- **Description:** Returns a welcome message.
- **Response:**

```json
{
    "message": "Welcome to the Minimal REST Framework!"
}
```

---

## 🛠️ **CUSTOMIZING THE FRAMEWORK**

You can add custom routes to the framework by using the `@app.route()` decorator. Here’s an example:

```python
@app.route("/new-endpoint", method="GET")
def new_endpoint():
    return {"message": "This is a new custom endpoint!"}
```

Add this function to the `minimal_rest_framework.py` file and restart the server to make the new endpoint available.

---

## 🔍 **EXAMPLE USAGE**

### Fetching Data (`GET /data`)

```bash
curl -X GET http://127.0.0.1:5000/data
```

**Response:**

```json
{
    "data": [1, 2, 3, 4, 5]
}
```

### Saving Information (`POST /info`)

```bash
curl -X POST http://127.0.0.1:5000/info
```

**Response:**

```json
{
    "status": "Information saved successfully!"
}
```

---

## 🛡️ **LICENSE**

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 🤝 **CONTRIBUTION**

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/ca1ik/Minimal-Rest-Api-Framework/issues).

1. **Fork the repository.**
2. **Create a feature branch:**

```bash
git checkout -b feature-name
```

3. **Commit your changes:**

```bash
git commit -m 'Add a new feature'
```

4. **Push to the branch:**

```bash
git push origin feature-name
```

5. **Open a pull request.**

---

## 🌐 **CONNECT**

- **GitHub:** [ca1ik](https://github.com/ca1ik)
- **Email:** [halicalix@gmail.com](mailto:halicalix@gmail.com)

---

## 📸 **SCREENSHOTS**

![Welcome Endpoint](https://i.ibb.co/9cx92gT/Welcome-Endpoint-Screenshot.png)

![Data Endpoint](https://i.ibb.co/DwFkYnZ/JSON-Response-Screenshot.png)

---

## 🔮 **ENHANCEMENTS**

### Purpose:
This project is designed for **small projects, quick prototyping,** and **learning Python fundamentals.**

### Roadmap:
- [ ] Add support for `PUT` and `DELETE` methods.

- [ ] Enable XML response format.

- [ ] Add multilingual support for localization.

### Support:
If you enjoy this project, consider starring it on GitHub or contributing to its development!

---

### 🎉 **THANK YOU FOR USING MINIMAL REST API FRAMEWORK!**

---
