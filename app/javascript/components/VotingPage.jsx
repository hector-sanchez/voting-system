import React, { useEffect, useState } from "react";

// Style constants defined outside component for reuse
const containerStyle = {
	maxWidth: "700px",
	margin: "40px auto",
	padding: "0 20px",
	fontFamily:
		'-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
};

const headingStyle = {
	textAlign: "left",
	marginBottom: "40px",
	color: "#1a1a1a",
	fontWeight: "700",
	fontSize: "2rem",
	letterSpacing: "-0.02em",
	lineHeight: "1.2",
};

const messageStyle = {
	backgroundColor: "#ffffff",
	padding: "30px",
	overflow: "hidden",
	textAlign: "center",
	fontSize: "1.1rem",
	color: "#666",
	lineHeight: "1.6",
};

const VotingPage = () => {
	const [isAuthenticated, setIsAuthenticated] = useState(false);
	const [isLoading, setIsLoading] = useState(true);

	useEffect(() => {
		// Check if user is authenticated
		const token = localStorage.getItem("authToken");

		if (!token) {
			// No token found, redirect to sign in
			window.location.href = "/sign_in";
			return;
		}

		// Token exists, user is authenticated
		setIsAuthenticated(true);
		setIsLoading(false);
	}, []);

	// Show loading while checking authentication
	if (isLoading) {
		return (
			<div style={containerStyle}>
				<h1 style={headingStyle}>Cast Your Vote</h1>
				<div style={messageStyle}>
					<p>Loading...</p>
				</div>
			</div>
		);
	}

	// User is authenticated, show voting page
	if (!isAuthenticated) {
		return null; // Will redirect, so don't render anything
	}

	return (
		<div style={containerStyle}>
			<h1 style={headingStyle}>Cast Your Vote</h1>

			<div style={messageStyle}>
				<p>Welcome to the voting page!</p>
				<p>
					This is where users will be able to vote for their favorite
					performers.
				</p>
				<p>
					<em>Voting functionality coming soon...</em>
				</p>
			</div>
		</div>
	);
};

export default VotingPage;
