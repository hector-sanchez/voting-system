import React, { useState, useEffect } from "react";

// Style constants for consistent styling
const headerStyle = {
	backgroundColor: "#ffffff",
	borderBottom: "2px solid #000000",
	padding: "0",
	position: "sticky",
	top: "0",
	zIndex: "1000",
	fontFamily:
		'-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
};

const containerStyle = {
	maxWidth: "1200px",
	margin: "0 auto",
	padding: "0 20px",
	display: "flex",
	justifyContent: "space-between",
	alignItems: "center",
	height: "60px",
};

const leftSectionStyle = {
	display: "flex",
	alignItems: "center",
	gap: "20px",
};

const rightSectionStyle = {
	display: "flex",
	alignItems: "center",
	gap: "15px",
};

const navLinkStyle = {
	color: "#000000",
	textDecoration: "none",
	fontWeight: "600",
	fontSize: "1rem",
	padding: "8px 16px",
	borderRadius: "4px",
	transition: "background-color 0.2s ease",
	cursor: "pointer",
};

const activeNavLinkStyle = {
	...navLinkStyle,
	backgroundColor: "#f0f0f0",
};

const greetingStyle = {
	color: "#000000",
	fontWeight: "600",
	fontSize: "1rem",
};

const logoutButtonStyle = {
	backgroundColor: "#000000",
	color: "#ffffff",
	border: "none",
	borderRadius: "4px",
	padding: "8px 16px",
	fontSize: "0.9rem",
	fontWeight: "600",
	cursor: "pointer",
	textTransform: "uppercase",
	letterSpacing: "0.5px",
};

const Navigation = () => {
	const [user, setUser] = useState(null);
	const [isLoading, setIsLoading] = useState(true);
	const [currentPath, setCurrentPath] = useState("");

	useEffect(() => {
		checkAuthentication();
		setCurrentPath(window.location.pathname);
	}, []);

	const checkAuthentication = () => {
		const token = localStorage.getItem("authToken");

		if (token) {
			try {
				// Decode JWT token to get user info
				const payload = JSON.parse(atob(token.split(".")[1]));
				setUser({
					name: payload.name,
					email: payload.email,
				});
			} catch (err) {
				console.error("Error parsing token:", err);
				localStorage.removeItem("authToken");
			}
		}

		setIsLoading(false);
	};

	const handleLogout = async () => {
		try {
			const token = localStorage.getItem("authToken");

			// Call logout endpoint
			await fetch("/sessions", {
				method: "DELETE",
				headers: {
					"Content-Type": "application/json",
					Accept: "application/json",
					Authorization: `Bearer ${token}`,
				},
			});

			// Clear token and redirect regardless of API response
			localStorage.removeItem("authToken");
			window.location.href = "/sign_in";
		} catch (err) {
			console.error("Logout error:", err);
			// Clear token and redirect even if API call fails
			localStorage.removeItem("authToken");
			window.location.href = "/sign_in";
		}
	};

	const navigateTo = (path) => {
		window.location.href = path;
	};

	if (isLoading) {
		return (
			<header style={headerStyle}>
				<div style={containerStyle}>
					<div style={leftSectionStyle}>
						<span>Loading...</span>
					</div>
				</div>
			</header>
		);
	}

	if (!user) {
		// User not signed in - show basic navigation with sign in link
		return (
			<header style={headerStyle}>
				<div style={containerStyle}>
					<nav style={leftSectionStyle}>
						<a
							href="/"
							style={currentPath === "/" ? activeNavLinkStyle : navLinkStyle}
							onClick={(e) => {
								e.preventDefault();
								navigateTo("/");
							}}
						>
							Voting Results
						</a>
					</nav>

					<div style={rightSectionStyle}>
						<a
							href="/sign_in"
							style={{
								...navLinkStyle,
								backgroundColor: "#000000",
								color: "#ffffff",
								borderRadius: "4px",
								padding: "8px 16px",
								textTransform: "uppercase",
								letterSpacing: "0.5px",
							}}
							onClick={(e) => {
								e.preventDefault();
								navigateTo("/sign_in");
							}}
						>
							Sign In
						</a>
					</div>
				</div>
			</header>
		);
	}

	return (
		<header style={headerStyle}>
			<div style={containerStyle}>
				<nav style={leftSectionStyle}>
					<a
						href="/vote"
						style={currentPath === "/vote" ? activeNavLinkStyle : navLinkStyle}
						onClick={(e) => {
							e.preventDefault();
							navigateTo("/vote");
						}}
					>
						Vote
					</a>
					<a
						href="/"
						style={currentPath === "/" ? activeNavLinkStyle : navLinkStyle}
						onClick={(e) => {
							e.preventDefault();
							navigateTo("/");
						}}
					>
						Voting Results
					</a>
				</nav>

				<div style={rightSectionStyle}>
					<span style={greetingStyle}>Hi {user.name}!</span>
					<button
						onClick={handleLogout}
						style={logoutButtonStyle}
					>
						Sign Out
					</button>
				</div>
			</div>
		</header>
	);
};

export default Navigation;
