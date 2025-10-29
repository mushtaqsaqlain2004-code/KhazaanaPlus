// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Khazaana+ — a simple per-user decentralized note store
/// @author ...
/// @notice Each user address keeps its own notes. Notes stored on-chain are public — encrypt before storing if you need privacy.
contract KhazaanaPlus {
    struct Note {
        uint256 id;         // index in the user's array
        string content;     // note text (recommend encrypting client-side)
        uint256 timestamp;  // block timestamp when created or last updated
        bool active;        // soft-delete flag
    }

    /// @dev mapping from user address -> their notes array
    mapping(address => Note[]) private notes;

    /// @notice Emitted when a note is created
    event NoteCreated(address indexed owner, uint256 indexed id, uint256 timestamp);

    /// @notice Emitted when a note is updated
    event NoteUpdated(address indexed owner, uint256 indexed id, uint256 timestamp);

    /// @notice Emitted when a note is deleted (soft-delete)
    event NoteDeleted(address indexed owner, uint256 indexed id, uint256 timestamp);

    /// @notice Add a new note for msg.sender. Consider encrypting `content` off-chain before calling.
    /// @param content The note content (string)
    /// @return id The note id (index) assigned to this note
    function addNote(string calldata content) external returns (uint256 id) {
        id = notes[msg.sender].length;
        notes[msg.sender].push(Note({
            id: id,
            content: content,
            timestamp: block.timestamp,
            active: true
        }));
        emit NoteCreated(msg.sender, id, block.timestamp);
    }

    /// @notice Returns all notes for a given user (including inactive/deleted ones)
    /// @param user The address whose notes to fetch
    /// @return userNotes Array of Note structs
    function getNotes(address user) external view returns (Note[] memory userNotes) {
        Note[] storage s = notes[user];
        uint256 len = s.length;
        userNotes = new Note[](len);
        for (uint256 i = 0; i < len; i++) {
            userNotes[i] = s[i];
        }
    }

    /// @notice Update the content of one of your notes
    /// @param id The note id (index)
    /// @param content New content for the note
    function updateNote(uint256 id, string calldata content) external {
        require(id < notes[msg.sender].length, "Invalid note id");
        Note storage n = notes[msg.sender][id];
        require(n.active, "Note deleted");
        n.content = content;
        n.timestamp = block.timestamp;
        emit NoteUpdated(msg.sender, id, block.timestamp);
    }

    /// @notice Soft-delete a note you own (marks inactive)
    /// @param id The note id (index)
    function deleteNote(uint256 id) external {
        require(id < notes[msg.sender].length, "Invalid note id");
        Note storage n = notes[msg.sender][id];
        require(n.active, "Already deleted");
        n.active = false;
        n.timestamp = block.timestamp;
        emit NoteDeleted(msg.sender, id, block.timestamp);
    }

    /// @notice Returns the total number of notes (including deleted) that a user has
    /// @param user Address to query
    /// @return count number of notes
    function totalNotes(address user) external view returns (uint256 count) {
        return notes[user].length;
    }

    /// @notice Helper: count only active notes for a user (read-only)
    /// @param user Address to query
    /// @return activeCount active (non-deleted) notes count
    function activeNoteCount(address user) external view returns (uint256 activeCount) {
        Note[] storage s = notes[user];
        for (uint256 i = 0; i < s.length; i++) {
            if (s[i].active) activeCount++;
        }
    }
}
