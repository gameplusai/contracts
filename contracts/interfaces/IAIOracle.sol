// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.24;

interface IAIOracle {
    struct Request {
        address requester;
        address receiver;
        string model;
        string requestDataType;
        string responseDataType;
        uint256 tokenLimit;
        uint256 tokenConsumed;
        bytes data;
        bool isFinalized;
        uint256 segmentCount;
        uint256 tokenFreezed;
    }

    // Event triggered when a request is created
    event AIRequestCreated(
        uint256 indexed requestId,
        address indexed requester,
        address indexed receiver, // Indicates the receiver to be called back
        bytes data,
        string model, // Model type (e.g., gpt-3.5, gpt-4o, dall-e)
        string requestDataType, // Request data type (e.g., plain:text, ipfs:json)
        string responseDataType, // Response data type (e.g., plain:text, ipfs:img)
        uint256 previousRequestId,
        uint256 tokenLimit // Maximum number of tokens allowed for this request
    );

    // Event triggered when a response is received, showing how many tokens were consumed
    event AIResponseReceived(
        uint256 indexed requestId,
        bytes32[] resultSegments, // Current response segments array
        bool isFinalSegment, // Whether this is the final segment
        uint256 tokensConsumed // Number of tokens consumed
    );

    // Event triggered when the response is continued
    event ContinueAIResponse(
        uint256 indexed requestId,
        uint256 additionalTokenLimit,
        uint256 newTokenLimit
    );

    // Event triggered when a user's balance is updated
    event BalanceUpdated(
        address indexed user,
        uint256 oldBalance,
        uint256 newBalance
    );

    /**
     * @dev Function to create an AI request. The requestId is generated by the oracle.
     * This method requires a fee to process the request.
     * @param data Data required for the AI model to process.
     * @param model The type and specific model (e.g., gpt-3.5, gpt-4o, dall-e).
     * @param requestDataType Type of request data (e.g., plain:text, ipfs:json).
     * @param responseDataType Type of response data (e.g., plain:text, ipfs:img).
     * @param previousRequestId Indicates if this request is based on a previous response (optional).
     * @param receiver Address to receive the callback.
     * @param tokenLimit Maximum number of tokens allowed for this request.
     * @return requestId The request identifier generated by the oracle.
     */
    function createAIRequest(
        bytes calldata data,
        string calldata model,
        string calldata requestDataType,
        string calldata responseDataType,
        uint256 previousRequestId,
        address receiver,
        uint256 tokenLimit
    ) external returns (uint256 requestId);

    /**
     * @dev Function for off-chain service to submit AI response segments.
     * @param requestId The request identifier generated by the oracle.
     * @param resultSegments The current response segments array (bytes32[]).
     * @param isFinalSegment Indicates if this is the final segment.
     * @param tokenConsumed Consumed token by this submission, each segment will consume 20000 gas
     */
    function submitAIResponseSegments(
        uint256 requestId,
        bytes32[] calldata resultSegments,
        bool isFinalSegment,
        uint256 tokenConsumed,
        uint256 gasLimit
    ) external;

    /**
     * @dev Function to allow the user to continue an on-chain request by increasing the token limit.
     * @param requestId The request identifier generated by the oracle.
     * @param additionalTokenLimit The additional token limit.
     */
    function continueAIResponse(
        uint256 requestId,
        uint256 additionalTokenLimit
    ) external;

    /**
     * @dev Function to get the response segments for a request.
     * @param requestId The request identifier generated by the oracle.
     * @param segmentIndex The starting index of the segments to retrieve.
     * @param segmentCount The number of segments to retrieve.
     * @return resultSegments The AI result segments array (bytes32[]).
     * @return isFinalSegment Indicates if this is the final segment.
     */
    function getAIResponseSegments(
        uint256 requestId,
        uint256 segmentIndex,
        uint256 segmentCount
    )
        external
        view
        returns (bytes32[] memory resultSegments, bool isFinalSegment);

    /**
     * @dev Function to get the total number of response segments for a request.
     * @param requestId The request identifier generated by the oracle.
     * @return segmentCount The total number of segments.
     */
    function getAIResponseSegmentCount(
        uint256 requestId
    ) external view returns (uint256 segmentCount);

    /**
     * @dev Function to get the list of allowed models.
     * @return models The list of allowed models (e.g., gpt-3.5, gpt-4o, dall-e).
     */
    function getAllowedModels() external view returns (string[] memory models);

    /**
     * @dev Function to get the allowed data types for a specific model and operation type.
     * @param model The name of the model (e.g., gpt-3.5, gpt-4o, dall-e).
     * @param operationType Operation type (0 for request, 1 for response).
     * @return dataTypes The list of allowed data types.
     */
    function getAllowedDataTypes(
        string calldata model,
        uint256 operationType // 0 for request, 1 for response
    ) external view returns (string[] memory dataTypes);

    /**
     * @dev Function to deposit AITokens for paying request fees.
     * @param amount The number of AITokens to deposit.
     */
    function depositTokens(uint256 amount) external;

    /**
     * @dev Function to get the AIToken balance of a specified user.
     *      1 token is for write 1 segment with 1 gwei.
     * @param user The address to query.
     * @return balance The current AIToken balance of the user.
     */
    function getTokenBalance(
        address user
    ) external view returns (uint256 balance);

    /**
     * @dev Function to withdraw AITokens.
     * @param amount The number of AITokens to withdraw.
     */
    function withdrawToken(uint256 amount) external;

    /**
     * @dev Function to withdraw AITokens to a specified address.
     * @param amount The number of AITokens to withdraw.
     * @param to The address to receive the AITokens.
     */
    function withdrawTokenTo(uint256 amount, address to) external;
}
