# !/bin/bash
# The line above makes your script executable.

# George Dunnery - 3/7/2019 - CS 5007
# This script is made possible by the free API <https://www.metaweather.com/api/>
# Instructor has permission to share this tutorial on Piazza board.



# Problem Statement: "I work in a windowless server room and I often wonder what the weather is outside."
# Name of Command: weather (see example usage below for terminal command)
# Example of its Usage:
#
# Start the bash script by typing one of the following two commands into the terminal.
#   $ ./myScript.sh
#   (OR)
#   $ sh myScript.sh
#
# Then a menu will be printed to the screen, and the user will need to select a campus (1-4).
#   -- NORTHEASTERN UNIVERSITY WEATHER --
#   1. Boston, MA
#   2. Charlotte, NC
#   3. San Francisco, CA
#   4. Seattle, WA
#   Please select a campus (1-4):
#
# After the user enters a number between 1 and 4, there will be a short delay as the data is served.
#   Retrieving the weather...
#
#   ---- WEATHER SUMMARY ----
#   Location:     (string, name of city)
#   Date:         (int year) - (int month) - (int day)
#   Description:  (string, describing weather)
#   Current Temp: (float) F
#   Low Temp:     (float) F
#   High Temp:    (float) F
#   Humidity:     (int) %
#   Air Pressure: (float) mbar
#   Visibility:   (float) mi
#   Wind:         (string, cardinal direction) at (float) mph
#   -------------------------



# HOW IT WORKS ------------------------------------------------------------------------------------
# STEP 1: Assign WOEIDs to the Northeatern Campuses.
# These are the locations of all the Northeastern University Align MSCS campuses. 
# The number is each area's WOEID (where on earth ID), which will be used to get the correct json data.
BOSTON=2367105
CHARLOTTE=2378426
SANFRANCISCO=2487956
SEATTLE=2490383

# STEP 2: Create a menu for the use to interact with.
# A menu of options is printed out to the user, and the script waits for a choice to be made.
echo "-- NORTHEASTERN UNIVERSITY WEATHER --"
echo "1. Boston, MA"
echo "2. Charlotte, NC"
echo "3. San Francisco, CA"
echo "4. Seattle, WA"
printf "Please select a campus (1-4): "

# The user's choice is stored as CHOICE, which will set the where on earth ID to use (WOEID).
read CHOICE

# STEP 3: Set the where on earth ID according to the user's choice.
# Now the WOEID is set using the number input by the user. This is similar to the Java switch statment.
case $CHOICE in
    [1])
        WOEID=$BOSTON
        ;;
    [2])
        WOEID=$CHARLOTTE
        ;;
    [3])
        WOEID=$SANFRANCISCO
        ;;
    [4])
        WOEID=$SEATTLE
        ;;
    *)
        # The default case is when the user makes a bad choice.
        # The user is informed the choice was invalid, and the script terminates.
        echo "An invalid campus was chosen. Try again with a number between 1-5."
        exit
        ;;
esac

# Step 4: Acquire JSON data using an API call and the WOEID.
# Let the user know there may be a small delay as the free-to-use service serves the requested data.
echo "Retrieving the weather..."
# This is a request through a free API for the weather data corresponding to the WOEID.
# Essentially, this call asks for the weather data for a particular location.
# The server will return a file full of JSON data, which will be parsed in the next step.
wget -q -O weather.json https://www.metaweather.com/api/location/$WOEID/

# STEP 5: Parse the JSON data to pick out information for the user.
# We are using grep to search for regex (regular expression) patterns in a '.json' file.
# JSON data takes the form "some_key":"some_value" between a set of curly braces - like a dictionary in Python.
# Nesting is allowed, and multiple JSON 'objects' can be separated by commas, which can make parsing tricky.
# There is a lot going on in these variable assignments, so let's walk through general the steps:
#   The grep utility is used to search for particular patterns.
#   The -o indicates that we only want to keep the data that matches the pattern.
#   The -E indicates we want to use the extended regex patterns.
#   The head -1 tells grep to stop at the first instance of a match (similarly, tail -1 asks for the last instance).
#   The vertical bar character | is used to "pipe" the data from the previous call to the next call.
#   Piping allows us to apply multiple methods to the same output.
# This is a tranlsation of the following line into English:
#   "Get the JSON key:value pair of 'the_temp' in the weather.json file but only keep the first occurence,
#   then extract a signed decimal value out of the results from the first search, and store it in a variable."
TEMPERATURE=$(grep -o -E '"the_temp":([-]?[0-9]+\.[0-9]+)' weather.json |
    head -1 | grep -o -E "[-]?[0-9]+\.[0-9]+")

LOWTEMP=$(grep -o -E '"min_temp":([-]?[0-9]+\.[0-9]+)' weather.json |
    head -1 | grep -o -E "[-]?[0-9]+\.[0-9]+")

HIGHTEMP=$(grep -o -E '"max_temp":([-]?[0-9]+\.[0-9]+)' weather.json |
    head -1 | grep -o -E "[-]?[0-9]+\.[0-9]+")

HUMIDITY=$(grep -o -E '"humidity":([-]?[0-9]+)' weather.json |
    head -1 | grep -o -E "[-]?[0-9]+")

LOCATION=$(grep -o -E '"title":"[[:alpha:]]+([[:space:]][[:alpha:]]+)*"' weather.json | tail -1 |
    grep -o -E ':"[[:alpha:]]+([[:space:]][[:alpha:]]+)*"' | cut -c 3- | sed 's/"$//')

DESCRIPTION=$(grep -o -E '"weather_state_name":"[[:alpha:]]+([[:space:]][[:alpha:]]+)*"' weather.json | head -1 |
    grep -o -E ':"[[:alpha:]]+([[:space:]][[:alpha:]]+)*"' | cut -c 3- | sed 's/"$//')

AIRPRESSURE=$(grep -o -E '"air_pressure":([-]?[0-9]+\.[0-9]+)' weather.json |
    head -1 | grep -o -E "[-]?[0-9]+\.[0-9]+")

VISIBILITY=$(grep -o -E '"visibility":([-]?[0-9]+\.[0-9]+)' weather.json |
    head -1 | grep -o -E "[-]?[0-9]+\.[0-9]+")

WINDDIRECTION=$(grep -o -E '"wind_direction_compass":"[[:alpha:]]+"' weather.json | head -1 |
    grep -o -E ':"[[:alpha:]]+"' | cut -c 3- | sed 's/"$//')

WINDSPEED=$(grep -o -E '"wind_speed":([-]?[0-9]+\.[0-9]+)' weather.json |
    head -1 | grep -o -E "[-]?[0-9]+\.[0-9]+")

DATE=$(grep -o -E '"applicable_date":"[0-9]+\-[0-9]+\-[0-9]+"' weather.json | head -1 |
    grep -o -E ':"[0-9]+\-[0-9]+\-[0-9]+"' | cut -c 3- | sed 's/"$//')

# STEP 6: Write a function to convert Celcius into Fahrenheit.
# The following is a simple function which will convert the temperature from celcius to fahrenheit. 
# Arguments are not defined between () in BASH. Instead, we refer to them as $1, $2, $3, etc. throughout
# the body of the function. When the funtion is called, the first argument after the function call is considered $1.
# For this function, I expect the caller to pass in one argument - the value in celcius.
# Return would end the program, but I want to hand the value back to the caller. To do this, I use command
# substitution with an echo call. For the caller to save the value, they must use the following format:
# VARIABLE=$(toFahrenheit $CELCIUS)
toFahrenheit() {
    # First, apply the formula C * (9/5) + 32 to convert degrees Celcius into degrees Fahrenheit.
    local RESULT=$(echo "$1 * (9 / 5) + 32" | bc)
    # Then round to two decimal places be setting scale to 2 and dividing by 1.
    echo "$RESULT"
}


# STEP 7: Write a function to round our values off to two decimal places for readability.
# Most of our numerical results will end up being printed with excessively long decimal places unless we
# do something about it. This function will take in one parameter, and return it rounded to two decimals by
# using the 'scale' command in 'bc' and dividing by 1 as an arbitrary operation to apply the scale.
toDecimal() {
    local RESULT=$(echo "scale=2; $1 / 1" | bc)
    echo "$RESULT"
}


# STEP 8: Report the collected data to the user in a readable format.
# In this step, we must ensure that the data comes out looking clean and easy to understand.
# All the decimal numbers are rounded off to two decimal places using the toDecimal function we wrote earlier.
# All the temperatures must be converted to Fahrenheit, since the users will be in the US.
# To format the temperatures in one step, we pass the result of the toFahrenheit function to the toDecimal function.
# Lastly, the unit symbols (F, %, mbar, etc.) are included after the numerical measurements in the weather summary.
echo ""
echo "---- WEATHER SUMMARY ----"
echo "Location:     $LOCATION"
echo "Date:         $DATE"
echo "Description:  $DESCRIPTION"
echo "Current Temp: $(toDecimal $(toFahrenheit $TEMPERATURE)) F"
echo "Low Temp:     $(toDecimal $(toFahrenheit $LOWTEMP)) F"
echo "High Temp:    $(toDecimal $(toFahrenheit $HIGHTEMP)) F"
echo "Humidity:     $HUMIDITY %"
echo "Air Pressure: $(toDecimal $AIRPRESSURE) mbar"
echo "Visibility:   $(toDecimal $VISIBILITY) mi"
echo "Wind:         $WINDDIRECTION at $(toDecimal $WINDSPEED) mph"
echo "--------------------------"


# STEP 9: Clean up.
# Now that the script is over, the weather.json file is no longer needed.
# Remove the '.json' file before terminating the script to avoid cluttering the user's hard drive.
rm weather.json
