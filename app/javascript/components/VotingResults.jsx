import React, { useState, useEffect } from "react";

const VotingResults = () => {
	const [results, setResults] = useState([]);
	const [totalVotes, setTotalVotes] = useState(0);
	const [isLoading, setIsLoading] = useState(true);
	const [error, setError] = useState(null);

	useEffect(() => {
		fetchVotingResults();
	}, []);

	const fetchVotingResults = async () => {
		try {
			setIsLoading(true);
			const response = await fetch("/voting_results.json", {
				headers: {
					Accept: "application/json",
				},
			});

			if (!response.ok) {
				throw new Error(`HTTP error! status: ${response.status}`);
			}

			const data = await response.json();
			setResults(data.results);
			setTotalVotes(data.total_votes);
			setIsLoading(false);
		} catch (e) {
			setError(`Failed to fetch voting results: ${e.message}`);
			setIsLoading(false);
		}
	};

	// I feel just as sad as you about these inline styles. I had  bunch of issues with
	// the styles not loading properly (or at all) and this is where I ended.
	// So, this is me capitulating to stress and just going with what works for the time being
	if (isLoading) {
		return (
			<div
				style={{
					textAlign: "left",
					padding: "40px",
					fontSize: "1.2rem",
					color: "#666",
				}}
			>
				Loading voting results...
			</div>
		);
	}

	if (error) {
		return (
			<div
				style={{
					textAlign: "center",
					padding: "40px",
					fontSize: "1.2rem",
					color: "#d32f2f",
					backgroundColor: "#ffeaea",
					border: "1px solid #ffcdd2",
					borderRadius: "4px",
					margin: "20px",
				}}
			>
				{error}
			</div>
		);
	}

	return (
		<div
			style={{
				maxWidth: "700px",
				margin: "40px auto",
				padding: "0 20px",
				fontFamily:
					'-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
			}}
		>
			<h1
				style={{
					textAlign: "left",
					marginBottom: "40px",
					color: "#1a1a1a",
					fontWeight: "700",
					fontSize: "2rem",
					letterSpacing: "-0.02em",
					lineHeight: "1.2",
				}}
			>
				Performer Voting Results
			</h1>

			<div
				style={{
					backgroundColor: "#ffffff",
					padding: "0",
					overflow: "hidden",
				}}
			>
				<ul
					style={{
						listStyleType: "none",
						padding: "0",
						margin: "0",
					}}
				>
					{results.map((item, index) => (
						<li
							key={item.performer.id}
							style={{
								display: "flex",
								justifyContent: "space-between",
								alignItems: "center",
								padding: "10px 15px",
								borderBottom:
									index === results.length - 1 ? "none" : "1px solid #000000",
							}}
						>
							<span
								style={{
									fontWeight: "600",
									color: "#000000",
									fontSize: "1rem",
									letterSpacing: "-0.01em",
								}}
							>
								{item.performer.name}
							</span>
							<span
								style={{
									fontWeight: "700",
									color: "#000000",
									padding: "8px 16px",
									minWidth: "60px",
									textAlign: "center",
								}}
							>
								{item.vote_count}
							</span>
						</li>
					))}
				</ul>
				<div
					style={{
						textAlign: "right",
						fontSize: "1.1rem",
						color: "#000000",
						fontWeight: "600",
						padding: "20px 30px",
						backgroundColor: "#f5f5f5",
						letterSpacing: "0.5px",
						textTransform: "uppercase",
						marginTop: "30px",
					}}
				>
					Total Votes: {totalVotes}
				</div>
			</div>
		</div>
	);
};

export default VotingResults;
