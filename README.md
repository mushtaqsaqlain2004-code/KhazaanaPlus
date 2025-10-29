# 🌟 Khazaana+ — Decentralized Note Storing System
<img width="1889" height="908" alt="Screenshot 2025-10-29 141511" src="https://github.com/user-attachments/assets/bec8df3c-a442-49e2-9022-eb4adcbf8cf6" />


> **Your personal on-chain vault for notes — secure, transparent, and censorship-resistant.**

---

## 🧠 Project Description

**Khazaana+** (meaning *Treasure Chest*) is a **decentralized note-storing dApp** built on blockchain technology.  
It allows users to **store, update, and manage personal notes** directly on the blockchain — no central servers, no third parties, and complete ownership of your data.

Each user (wallet address) has their **own note space**, and all operations — adding, editing, deleting — are securely recorded on-chain.

---

## 🚀 What It Does

- Lets users **create, view, and manage notes** from their own wallet.
- Stores all data on the blockchain — **no centralized database**.
- Provides transparency and immutability — every change is verifiable.
- Emits **events** for easy integration with frontends (React, Ethers.js, etc.).

> ⚠️ **Note:** Blockchain data is public. For private notes, you should **encrypt your note content off-chain** before storing.

---

## ✨ Features

✅ **Per-user storage** — Each wallet keeps its own set of notes.  
✅ **Add / Update / Delete notes** — Full CRUD support.  
✅ **Soft delete** — Notes can be marked inactive instead of permanently erased.  
✅ **Timestamps** — Automatically tracks when each note was created or modified.  
✅ **Events emitted** — Easy to listen to note actions from frontend apps.  
✅ **Gas efficient & minimal** — Optimized for Celo / EVM-compatible chains.  

---

## 🌐 Deployed Smart Contract

- **Network:** Celo Sepolia Testnet  
- **Contract Address:** [0xFA4323e511eef408901F925b779287469a207823](https://celo-sepolia.blockscout.com/address/0xFA4323e511eef408901F925b779287469a207823)  
- **Block Explorer:** [View on Blockscout](https://celo-sepolia.blockscout.com/address/0xFA4323e511eef408901F925b779287469a207823)

---

## 🧩 Smart Contract Code

```solidity
//paste your code
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
