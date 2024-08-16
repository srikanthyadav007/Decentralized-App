pragma solidity ^0.8.0;

contract FakeNewsDApp {
    struct Voter {
        bool isRegistered;
        uint unique_id; //Unique Identifier such as PAN number or Adhaar Number
        mapping(bytes32 => bool) calculated; // mapping to track whether calculated trustworthiness for news items or not
        mapping(bytes32 => bool) his_vote; //Mapping of his vote(0 or 1) for the news item
        mapping(string => uint) trustworthiness; // trustworthiness for each field
        uint wallet; // wallet to store incentives
    }

    //struct to store the article's hash value along with the article itself
    struct NewsArticle {
        bytes32 newsHash;
        string article;
    }

    mapping(uint => Voter) public voters;
    mapping(bytes32 => uint) public newsRating; // mapping to store news ratings (Final declaration whether news is true or fake)

    uint constant DECIMALS = 1000; // Number of decimals to use for floating point representation


    // Lists of words for each field
    string[] public technologyWords = ["technology", "innovation", "digital", "computing", "internet", "software", "hardware", "artificial", "intelligence", "blockchain"];
    string[] public healthWords = ["health", "medical", "wellness", "medicine", "fitness", "pandemic", "vaccine", "nutrition", "mental", "disease"];
    string[] public sportsWords = ["sports", "athletics", "games", "competition", "tournament", "football", "basketball", "cricket", "tennis", "soccer"];
    string[] public scienceWords = ["science", "research", "discovery", "experiment", "theory", "physics", "chemistry", "biology", "astronomy", "environment"];
    string[] public businessWords = ["business", "finance", "economy", "market", "industry", "investment", "startup", "entrepreneurship", "management", "strategy"];
    string[] public entertainmentWords = ["entertainment", "arts", "celebrity", "film", "music", "television", "cinema", "performance", "celebration", "culture"];
    string[] public crimeWords = ["crime", "law", "police", "justice", "security", "violence", "corruption", "fraud", "theft", "terrorism"];


    // Modifier to restrict access to registered voters only
    modifier onlyRegisteredVoter() {
        require(voters[unique_id].isRegistered, "Only registered voters can access this function");
        _;
    }

    // Function for users to register as fact-checkers
    function register(uint unique_id) external { //Unique Number such as Adhaar Number for Registration
        require(!voters[unique_id].isRegistered, "Already registered");
        voters[unique_id].isRegistered = true;
    }

    // Function to store the article and return its hash value
    function storeArticle(string memory article) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(article));
    }


    // Function to calculate the news article field based on word matching score
    function calculateField(string memory article) public view returns (string memory) {
        // Initialize scores for each field
        uint maxScore = 0;
        string memory field;

        // Calculate matching score for each field
        uint technologyScore = calculateScore(article, technologyWords);
        if (technologyScore > maxScore) {
            maxScore = technologyScore;
            field = "Technology";
        }

        uint healthScore = calculateScore(article, healthWords);
        if (healthScore > maxScore) {
            maxScore = healthScore;
            field = "Health";
        }

        uint sportsScore = calculateScore(article, sportsWords);
        if (sportsScore > maxScore) {
            maxScore = sportsScore;
            field = "Sports";
        }

        uint scienceScore = calculateScore(article, scienceWords);
        if (scienceScore > maxScore) {
            maxScore = scienceScore;
            field = "Science";
        }

        uint businessScore = calculateScore(article, businessWords);
        if (businessScore > maxScore) {
            maxScore = businessScore;
            field = "Business";
        }

        uint entertainmentScore = calculateScore(article, entertainmentWords);
        if (entertainmentScore > maxScore) {
            maxScore = entertainmentScore;
            field = "Entertainment";
        }

        uint crimeScore = calculateScore(article, crimeWords);
        if (crimeScore > maxScore) {
            maxScore = crimeScore;
            field = "Crime";
        }

        return field;
    }

    // Function to calculate matching score for a field
    function calculateScore(string memory article, string[] memory words) internal pure returns (uint) {
        uint score = 0;
        for (uint i = 0; i < words.length; i++) {
            if (containsWord(article, words[i])) {
                score++;
            }
        }
        return score;
    }

    // Function to check if the article contains a specific word
    function containsWord(string memory article, string memory word) internal pure returns (bool) {
        bytes memory a = bytes(article);
        bytes memory b = bytes(word);
        uint index = 0;
        while (index < a.length) {
            if (a[index] == b[0]) {
                uint j = 1;
                while (j < b.length && (index + j) < a.length && a[index + j] == b[j]) {
                    j++;
                }
                if (j == b.length) {
                    return true;
                }
            }
            index++;
        }
        return false;
    }


    // Function for fact-checkers to vote during bootstrapping (known news rating) and Updating the Trustworthiness
    function bootstrappingTrustWorthiness(bytes32 newsHash, bool isFake, string memory field) external onlyRegisteredVoter {
        require(!voters[unique_id].calculated[newsHash], "Already calculated for this news");
        
        // Update trustworthiness based on the accuracy of the vote
        if ((isFake && newsRating[newsHash] == 0) || (!isFake && newsRating[newsHash] == 1)) {
            voters[unique_id].trustworthiness[field]++;
        }
        voters[unique_id].his_vote[newsHash] =  !(isFake);
        
        // Mark news item as calculated
        voters[unique_id].calculated[newsHash] = true;
    }




    // Function to find whether news is true or fake
    function findingNewsrate(bytes32 newsHash, string memory field) internal {
        // Calculate weighted sum of votes
        uint weightedSum;
        uint totalWeight;
        for (uint i = 0; i < voters.length; i++) {
            if (voters[i].calculated[newsHash]) {
                weightedSum += voters[i].trustworthiness[field] * (voters[i].his_vote[newsHash]);
                totalWeight += voters[i].trustworthiness[field];
            }
        }
        
        // Update news rating based on the weighted sum
        if (totalWeight > 0 && (weightedSum * 1000) / totalWeight <= 500) {
            newsRating[newsHash] = 0;
        } else {
            newsRating[newsHash] = 1;
        }
    }

    // Function for Re-evaluating TrustWorthiness
    function reEvaluateTrustWorthiness(bytes32 newsHash, bool isFake, string memory field) external onlyRegisteredVoter {
        require(!voters[unique_id].calculated[newsHash], "Already calculated for this news");
        
        // Update trustworthiness based on the accuracy of the vote
        if ((isFake && newsRating[newsHash] == 0) || (!isFake && newsRating[newsHash] == 1)) {
            voters[unique_id].trustworthiness[field]++;
        }
        voters[unique_id].his_vote[newsHash] =  !(isFake);
    
        voters[unique_id].calculated[newsHash] = true; // Mark news item as calculated
    }


    // Function to calculate trustworthiness of a voter in a field
    function getTrustworthiness(uint voter, string memory field) external view returns (uint) {
        return voters[voter].trustworthiness[field];
    }

    // Function to convert float to uint
    function floatToUint(uint value) internal pure returns (uint) {
        return value / DECIMALS;
    }

    // // Function to add incentives to a voter's wallet
    // function addIncentive(uint voter, uint amount) external {
    //     voters[voter].wallet += amount;
    // }


    // Function to add incentives to a voter's wallet if their prediction matches the news rating
    function addIncentive(uint voter, uint amount, bytes32 newsHash) external {
        require(voters[voter].his_vote[newsHash] == newsRating[newsHash], "Prediction does not match news rating");
        voters[voter].wallet += amount;
    }

    // Function to retrieve the overall rating of a news item
    function getNewsRating(bytes32 newsHash) external view returns (uint) {
        return newsRating[newsHash];
    }
}
