import React, { useEffect, useState } from "react";

// Style constants defined outside component for reuse
const containerStyle = {
	maxWidth: "900px",
	margin: "40px auto",
	padding: "0 20px",
	fontFamily:
		'-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
};

const headingStyle = {
	textAlign: "center",
	marginBottom: "40px",
	color: "#1a1a1a",
	fontWeight: "700",
	fontSize: "2rem",
	letterSpacing: "-0.02em",
	lineHeight: "1.2",
	gridColumn: "1 / -1", // Span across both columns
};

const gridContainerStyle = {
	display: "grid",
	gridTemplateColumns: "1fr 1fr",
	gap: "40px",
	alignItems: "start",
};

const columnStyle = {
	backgroundColor: "#ffffff",
	padding: "30px",
	border: "1px solid #e0e0e0",
	borderRadius: "6px",
};

const columnHeadingStyle = {
	fontSize: "1.3rem",
	fontWeight: "700",
	color: "#1a1a1a",
	marginBottom: "20px",
	letterSpacing: "-0.01em",
};

const radioListStyle = {
	listStyleType: "none",
	padding: "0",
	margin: "0 0 20px 0",
};

const radioItemStyle = {
	marginBottom: "12px",
	display: "flex",
	alignItems: "center",
};

const radioInputStyle = {
	marginRight: "10px",
	transform: "scale(1.2)",
};

const radioLabelStyle = {
	fontSize: "1rem",
	color: "#1a1a1a",
	cursor: "pointer",
	fontWeight: "500",
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
	cursor: "pointer",
	textTransform: "uppercase",
	letterSpacing: "0.5px",
	width: "100%",
	marginTop: "10px",
};

const disabledButtonStyle = {
	...buttonStyle,
	backgroundColor: "#cccccc",
	cursor: "not-allowed",
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
	marginBottom: "10px",
};

const errorStyle = {
	backgroundColor: "#ffeaea",
	color: "#d32f2f",
	padding: "12px 16px",
	border: "1px solid #ffcdd2",
	marginBottom: "20px",
	fontSize: "0.9rem",
	borderRadius: "6px",
};

const successStyle = {
	backgroundColor: "#e8f5e8",
	color: "#2e7d2e",
	padding: "12px 16px",
	border: "1px solid #4caf50",
	marginBottom: "20px",
	fontSize: "0.9rem",
	borderRadius: "6px",
};

const VotingPage = () => {
	const [isAuthenticated, setIsAuthenticated] = useState(false);
	const [isLoading, setIsLoading] = useState(true);
	const [hasVoted, setHasVoted] = useState(false);
	const [performers, setPerformers] = useState([]);
	const [selectedPerformer, setSelectedPerformer] = useState("");
	const [newPerformerName, setNewPerformerName] = useState("");
	const [isVoting, setIsVoting] = useState(false);
	const [isCreating, setIsCreating] = useState(false);
	const [error, setError] = useState(null);
	const [success, setSuccess] = useState(null);

	useEffect(() => {
		checkAuthAndLoadData();
	}, []);

	const checkAuthAndLoadData = async () => {
		// Check if user is authenticated
		const token = localStorage.getItem("authToken");

		if (!token) {
			// No token found, redirect to sign in
			window.location.href = "/sign_in";
			return;
		}

		try {
			// For now, we'll check voting status via API call
			// TODO: Store has_voted flag in token for better UX

			// Load performers
			await loadPerformers();

			setIsAuthenticated(true);
		} catch (err) {
			console.error("Error checking auth:", err);
			window.location.href = "/sign_in";
			return;
		} finally {
			setIsLoading(false);
		}
	};

	const loadPerformers = async () => {
		try {
			const response = await fetch("/performers", {
				headers: {
					Accept: "application/json",
				},
			});

			if (response.ok) {
				const data = await response.json();
				setPerformers(data.performers);
			} else {
				setError("Failed to load performers");
			}
		} catch (err) {
			setError(`Error loading performers: ${err.message}`);
		}
	};

	const handleVoteSubmit = async (e) => {
		e.preventDefault();

		if (!selectedPerformer) {
			setError("Please select a performer to vote for");
			return;
		}

		setIsVoting(true);
		setError(null);
		setSuccess(null);

		try {
			const token = localStorage.getItem("authToken");
			const csrfToken = document
				.querySelector('meta[name="csrf-token"]')
				?.getAttribute("content");

			const response = await fetch("/votes", {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
					Accept: "application/json",
					Authorization: `Bearer ${token}`,
					"X-CSRF-Token": csrfToken,
				},
				body: JSON.stringify({
					vote: {
						performer_id: selectedPerformer,
					},
				}),
			});

			const data = await response.json();

			if (response.ok) {
				setSuccess("Vote cast successfully!");
				setHasVoted(true);
				// Redirect to results immediately
				window.location.href = "/";
			} else {
				setError(data.error || "Failed to cast vote");
			}
		} catch (err) {
			setError(`Network error: ${err.message}`);
		} finally {
			setIsVoting(false);
		}
	};

	const handleCreatePerformer = async (e) => {
		e.preventDefault();

		if (!newPerformerName.trim()) {
			setError("Please enter a performer name");
			return;
		}

		setIsCreating(true);
		setError(null);
		setSuccess(null);

		try {
			const token = localStorage.getItem("authToken");
			const csrfToken = document
				.querySelector('meta[name="csrf-token"]')
				?.getAttribute("content");

			const response = await fetch("/performers", {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
					Accept: "application/json",
					Authorization: `Bearer ${token}`,
					"X-CSRF-Token": csrfToken,
				},
				body: JSON.stringify({
					performer: {
						name: newPerformerName.trim(),
					},
				}),
			});

			const data = await response.json();

			if (response.ok) {
				setSuccess("Performer created and vote cast successfully!");
				setHasVoted(true);
				// Redirect to results immediately
				window.location.href = "/";
			} else {
				setError(data.error || "Failed to create performer");
			}
		} catch (err) {
			setError(`Network error: ${err.message}`);
		} finally {
			setIsCreating(false);
		}
	};

	// Show loading while checking authentication
	if (isLoading) {
		return (
			<div style={containerStyle}>
				<h1 style={headingStyle}>Cast your vote today!</h1>
				<div style={columnStyle}>
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
			<h1 style={headingStyle}>Cast your vote today!</h1>

			{error && <div style={errorStyle}>{error}</div>}
			{success && <div style={successStyle}>{success}</div>}

			<div style={gridContainerStyle}>
				{/* Left Column - Vote for Existing Performer */}
				<div style={columnStyle}>
					<h2 style={columnHeadingStyle}>Vote for a Performer</h2>
					
					<form onSubmit={handleVoteSubmit}>
						<ul style={radioListStyle}>
							{performers.map((performer) => (
								<li
									key={performer.id}
									style={radioItemStyle}
								>
									<input
										type="radio"
										id={`performer-${performer.id}`}
										name="performer"
										value={performer.id}
										checked={selectedPerformer === performer.id.toString()}
										onChange={(e) => setSelectedPerformer(e.target.value)}
										style={radioInputStyle}
										disabled={hasVoted}
									/>
									<label
										htmlFor={`performer-${performer.id}`}
										style={radioLabelStyle}
									>
										{performer.name}
									</label>
								</li>
							))}
						</ul>
						<button
							type="submit"
							disabled={isVoting || !selectedPerformer || hasVoted}
							style={
								!selectedPerformer || isVoting || hasVoted
									? disabledButtonStyle
									: buttonStyle
							}
						>
							{isVoting ? "Voting..." : "Vote"}
						</button>
					</form>
				</div>

				{/* Right Column - Create New Performer */}
				<div style={columnStyle}>
					<h2 style={columnHeadingStyle}>Add a New Performer</h2>
					
					<form onSubmit={handleCreatePerformer}>
						<input
							type="text"
							value={newPerformerName}
							onChange={(e) => setNewPerformerName(e.target.value)}
							placeholder="Enter performer name"
							style={inputStyle}
							disabled={isCreating || hasVoted}
						/>
						<button
							type="submit"
							disabled={isCreating || !newPerformerName.trim() || hasVoted}
							style={
								!newPerformerName.trim() || isCreating || hasVoted
									? disabledButtonStyle
									: buttonStyle
							}
						>
							{isCreating ? "Creating..." : "Create & Vote"}
						</button>
					</form>
				</div>
			</div>
		</div>
	);
};

export default VotingPage;
