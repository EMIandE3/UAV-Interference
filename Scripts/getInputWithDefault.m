function variable = getInputWithDefault(prompt, defaultValue)
    % getInputWithDefault: Prompts the user for input and returns the input or a default value if no input is provided.
    %
    %   variable = getInputWithDefault(prompt, defaultValue) prompts the user with the given prompt.
    %   If the user presses Enter without typing anything, the function returns the defaultValue.
    %
    %   Example:
    %       value = getInputWithDefault('Enter a number (default 10): ', 10);

    userInput = input(prompt, 's'); % 's' specifies string input
    if isempty(userInput) || strcmp(userInput, '')
        variable = num2str(defaultValue);
    else
        variable = userInput;
    end
end
