# This file creates seed data for the voting application
# The data can be loaded with the bin/rails db:seed command

# Clear existing data to avoid duplicates
puts "Cleaning database..."
Vote.destroy_all
Performer.destroy_all
User.destroy_all

# Create performers
puts "Creating performers..."
performers = [
  { name: "Taylor Swift" },
  { name: "Beyoncé" },
  { name: "Bruno Mars" },
  { name: "Adele" },
  { name: "Ed Sheeran" }
]

created_performers = performers.map do |performer_attrs|
  Performer.create!(performer_attrs)
end
puts "Created #{Performer.count} performers"

# Create users with passwords
puts "Creating users..."
names = [
  "Alice Johnson", "Bob Smith", "Charlie Brown", "Diana Prince", "Ethan Hunt",
  "Fiona Green", "George Wilson", "Hannah Davis", "Ian Malcolm", "Julia Roberts",
  "Kevin Hart", "Laura Palmer", "Michael Scott", "Nina Williams", "Oscar Wilde",
  "Paula Abdul", "Quincy Jones", "Rachel Green", "Steve Jobs", "Tina Turner",
  "Uma Thurman", "Victor Hugo", "Wendy Darling", "Xavier Charles", "Yuki Tanaka",
  "Zoe Baker", "Aaron Paul", "Bella Swan", "Connor MacLeod", "Donna Noble"
]

30.times do |i|
  User.create!(
    name: names[i] || "User #{i+1}",
    email: "user#{i+1}@example.com",
    password: "password123",
    zipcode: "#{10000 + rand(89999)}"
  )
end
puts "Created #{User.count} users"

# Create votes - each user votes for a random performer
puts "Creating votes..."
User.all.each do |user|
  # Randomly decide if this user will vote (80% chance)
  if rand < 0.8
    performer = created_performers.sample
    Vote.create!(
      user: user,
      performer: performer
    )
    puts "User #{user.email} voted for #{performer.name}"
  else
    puts "User #{user.email} did not vote"
  end
end
puts "Created #{Vote.count} votes"

# Print voting results
vote_counts = Vote.group(:performer_id).count
puts "\nVoting results:"
Performer.all.each do |performer|
  votes = vote_counts[performer.id] || 0
  puts "#{performer.name}: #{votes} votes"
end
puts "Total votes: #{Vote.count}"
