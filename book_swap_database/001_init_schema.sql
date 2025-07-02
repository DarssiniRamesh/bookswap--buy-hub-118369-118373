-- Book Swap Platform Initial Schema
-- This script sets up the Users, Books, Transactions, and SwapRequests tables

-- ================================
-- USERS TABLE
-- Stores registered user information
-- ================================
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY, -- Unique user ID
    name VARCHAR(100) NOT NULL, -- Full name of user
    email VARCHAR(255) NOT NULL UNIQUE, -- User email, must be unique
    password_hash VARCHAR(255) NOT NULL, -- Hashed password (never store raw passwords!)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Registration timestamp
);

-- ===================================
-- BOOKS TABLE
-- Stores details about books listed for swap/sale
-- ===================================
CREATE TABLE IF NOT EXISTS books (
    id SERIAL PRIMARY KEY, -- Unique book ID
    owner_id INTEGER NOT NULL, -- Reference to users(id), who owns the book
    title VARCHAR(200) NOT NULL, -- Book title
    author VARCHAR(150), -- Book author
    description TEXT, -- Book description/summary
    genre VARCHAR(100), -- Book genre/category
    condition VARCHAR(50), -- e.g., 'New', 'Good', 'Worn'
    price NUMERIC(10, 2), -- Price for direct purchase (nullable for swap-only books)
    is_available BOOLEAN DEFAULT TRUE, -- Book availability status
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- When book was listed
    -- Foreign key constraint - book owner must exist in users
    CONSTRAINT fk_books_owner FOREIGN KEY (owner_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- =====================================================
-- TRANSACTIONS TABLE
-- Records sales or completed swap transactions between users
-- =====================================================
CREATE TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY, -- Unique transaction ID
    buyer_id INTEGER NOT NULL, -- Reference to users(id) of the buyer
    seller_id INTEGER NOT NULL, -- Reference to users(id) of the seller
    book_id INTEGER NOT NULL, -- Reference to books(id) for the transaction
    transaction_type VARCHAR(20) NOT NULL, -- 'purchase' or 'swap'
    -- Details for swap: If transaction_type is 'swap', the swap_request_id will indicate the originating swap
    swap_request_id INTEGER, -- Reference to swap_requests(id), nullable (for swap transactions)
    amount NUMERIC(10,2), -- Transaction amount (for purchases)
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- When the transaction was completed
    status VARCHAR(20) NOT NULL DEFAULT 'completed', -- Status of transaction (e.g. 'completed', 'cancelled', etc.)
    -- Foreign key constraints
    CONSTRAINT fk_transactions_buyer FOREIGN KEY (buyer_id) REFERENCES users(id),
    CONSTRAINT fk_transactions_seller FOREIGN KEY (seller_id) REFERENCES users(id),
    CONSTRAINT fk_transactions_book FOREIGN KEY (book_id) REFERENCES books(id),
    CONSTRAINT fk_transactions_swapreq FOREIGN KEY (swap_request_id) REFERENCES swap_requests(id)
);

-- =============================================
-- SWAP REQUESTS TABLE
-- Store and track book swap proposals between users
-- =============================================
CREATE TABLE IF NOT EXISTS swap_requests (
    id SERIAL PRIMARY KEY, -- Unique swap request ID
    requester_id INTEGER NOT NULL, -- User who initiates the swap (users.id)
    offered_book_id INTEGER NOT NULL, -- Book id (books.id) user is offering
    requested_book_id INTEGER NOT NULL, -- Book id (books.id) user wants in exchange
    recipient_id INTEGER NOT NULL, -- User who owns the requested book (users.id)
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- 'pending', 'accepted', 'declined', 'cancelled', 'completed'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp for request creation
    responded_at TIMESTAMP, -- When owner acted on the request (nullable)
    -- Foreign key constraints
    CONSTRAINT fk_swap_requester FOREIGN KEY (requester_id) REFERENCES users(id),
    CONSTRAINT fk_swap_offered_book FOREIGN KEY (offered_book_id) REFERENCES books(id),
    CONSTRAINT fk_swap_requested_book FOREIGN KEY (requested_book_id) REFERENCES books(id),
    CONSTRAINT fk_swap_recipient FOREIGN KEY (recipient_id) REFERENCES users(id),
    -- Unique constraint: prevent duplicate active swap proposals between same users/books
    CONSTRAINT uq_swap_active UNIQUE (requester_id, offered_book_id, requested_book_id, recipient_id, status)
);

-- ================================
-- INDEXES FOR COMMON QUERIES
-- ================================
CREATE INDEX IF NOT EXISTS idx_books_owner ON books(owner_id);
CREATE INDEX IF NOT EXISTS idx_transactions_buyer ON transactions(buyer_id);
CREATE INDEX IF NOT EXISTS idx_transactions_seller ON transactions(seller_id);
CREATE INDEX IF NOT EXISTS idx_swap_requests_requester ON swap_requests(requester_id);
CREATE INDEX IF NOT EXISTS idx_swap_requests_recipient ON swap_requests(recipient_id);

-- ========================================
-- SAMPLE SEED DATA (OPTIONAL)
-- Uncomment below section to add sample data for local testing of schema
-- ========================================
-- INSERT INTO users (name, email, password_hash) VALUES
--     ('Alice Example', 'alice@example.com', 'hashed-password-1'),
--     ('Bob Example', 'bob@example.com', 'hashed-password-2');

-- INSERT INTO books (owner_id, title, author, description, genre, condition, price)
-- VALUES (1, 'Pride and Prejudice', 'Jane Austen', 'Classic romance novel', 'Classic', 'Good', 12.00);

-- ========================================
-- END OF INIT SCRIPT FOR BOOK SWAP PLATFORM
-- ========================================
