import random

def guess_game():
    secret_number = random.randint(1, 10)
    attempts = 3
    i = 0

    print("Welcome to the Number Guessing Game!")
    print("Guess a number between 1 and 10.")
    print(secret_number)
    
    while attempts > 0:
        try:
            
            guess = int(input("Enter your guess: "))
            attempts -= 1
            i += 1

            if guess < secret_number:
                print("Too low! Try again.")
                print(f"You have {attempts} attempts remining")
            elif guess > secret_number:
                print("Too high! Try again.")
                print(f"You have {attempts} trials remining")
            else:
                print(f"Congratulations! You guessed the number in {i} attempts.")
                break
        except ValueError:
            print("Please enter a valid number.")
        if attempts == 0:
            print("You have used up all you attempt")
            print("thanks for playing")

        
guess_game()
