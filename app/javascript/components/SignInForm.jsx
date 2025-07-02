import React, { useState } from "react";

const SignInForm = () => {
	const [formData, setFormData] = useState({
		email: "",
		zipcode: "",
		password: "",
	});
	const [isLoading, setIsLoading] = useState(false);
	const [error, setError] = useState(null);
	const [success, setSuccess] = useState(null);

	const handleInputChange = (e) => {
		const { name, value } = e.target;
		setFormData((prev) => ({
			...prev,
			[name]: value,
		}));
	};

	const handleSubmit = async (e) => {
		e.preventDefault();
		setIsLoading(true);
		setError(null);
		setSuccess(null);

		try {
			// Get CSRF token from meta tag
			const csrfToken = document
				.querySelector('meta[name="csrf-token"]')
				?.getAttribute("content");

			const response = await fetch("/sessions", {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
					Accept: "application/json",
					"X-CSRF-Token": csrfToken,
				},
				body: JSON.stringify({
					session: formData,
				}),
			});

			const data = await response.json();

			if (response.ok) {
				setSuccess("Login successful!");
				// Store token if needed
				if (data.token) {
					localStorage.setItem("authToken", data.token);
				}
				// Redirect based on voting status
				const redirectPath = data.redirect_to || "/";
				window.location.href = redirectPath;
			} else {
				setError(data.error || "Login failed");
			}
		} catch (err) {
			setError(`Network error: ${err.message}`);
		} finally {
			setIsLoading(false);
		}
	};

	const containerStyle = {
		maxWidth: "400px",
		margin: "60px auto", // Keep larger margin for sign-in since no nav header shown
		padding: "0 20px",
		fontFamily:
			'-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
	};

	const headingStyle = {
		textAlign: "left",
		marginBottom: "40px",
		color: "#1a1a1a",
		fontWeight: "700",
		fontSize: "1.5rem",
		letterSpacing: "-0.02em",
		lineHeight: "2.5",
	};

	const formStyle = {
		backgroundColor: "#ffffff",
		overflow: "hidden",
	};

	const fieldGroupStyle = {
		marginBottom: "20px",
	};

	const labelStyle = {
		display: "block",
		marginBottom: "8px",
		fontWeight: "600",
		color: "#000000",
		fontSize: "1rem",
		letterSpacing: "-0.01em",
	};

	const inputStyle = {
		width: "100%",
		padding: "12px 16px",
		border: "1px solid #000000",
		borderRadius: "6px",
		backgroundColor: "#ffffff",
		fontSize: "1rem",
		color: "#000000",
		boxSizing: "border-box",
		outline: "none",
	};

	const buttonStyle = {
		display: "inline-block",
		padding: "12px 24px",
		backgroundColor: "#000000",
		color: "#ffffff",
		border: "none",
		borderRadius: "6px",
		fontSize: "1rem",
		fontWeight: "700",
		cursor: isLoading ? "not-allowed" : "pointer",
		textTransform: "uppercase",
		letterSpacing: "0.5px",
		marginTop: "10px",
	};

	const errorStyle = {
		backgroundColor: "#ffeaea",
		color: "#d32f2f",
		padding: "12px 16px",
		border: "1px solid #ffcdd2",
		marginBottom: "20px",
		fontSize: "0.9rem",
	};

	const successStyle = {
		backgroundColor: "#e8f5e8",
		color: "#2e7d2e",
		padding: "12px 16px",
		border: "1px solid #4caf50",
		marginBottom: "20px",
		fontSize: "0.9rem",
	};

	return (
		<div style={containerStyle}>
			<h1 style={headingStyle}>Sign In</h1>

			<div style={formStyle}>
				{error && <div style={errorStyle}>{error}</div>}
				{success && <div style={successStyle}>{success}</div>}

				<form onSubmit={handleSubmit}>
					<div style={fieldGroupStyle}>
						<label
							htmlFor="email"
							style={labelStyle}
						>
							Email
						</label>
						<input
							type="email"
							id="email"
							name="email"
							value={formData.email}
							onChange={handleInputChange}
							required
							style={inputStyle}
							placeholder="Enter your email"
						/>
					</div>

					<div style={fieldGroupStyle}>
						<label
							htmlFor="password"
							style={labelStyle}
						>
							Password
						</label>
						<input
							type="password"
							id="password"
							name="password"
							value={formData.password}
							onChange={handleInputChange}
							required
							style={inputStyle}
							placeholder="Enter your password"
						/>
					</div>

					<div style={fieldGroupStyle}>
						<label
							htmlFor="zipcode"
							style={labelStyle}
						>
							Zip Code
						</label>
						<input
							type="text"
							id="zipcode"
							name="zipcode"
							value={formData.zipcode}
							onChange={handleInputChange}
							required
							style={inputStyle}
							placeholder="Enter your zip code"
						/>
					</div>

					<button
						type="submit"
						disabled={isLoading}
						style={buttonStyle}
					>
						{isLoading ? "Signing In..." : "Sign In"}
					</button>
				</form>
			</div>
		</div>
	);
};

export default SignInForm;
