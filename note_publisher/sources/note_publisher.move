#[allow(lint(self_transfer))]
module note_publisher::note_publisher{
    use std::string::{Self, String};

    public struct NoteRecord has key, store {
        id: UID,
        title: String,
        blob_id: String,
        publisher: address,
        category: String,
    }

    public fun publish_note(
        title: vector<u8>,
        blob_id: vector<u8>,
        category: vector<u8>,
        ctx: &mut TxContext
    ) {
        let record = NoteRecord {
            id: object::new(ctx),
            title: string::utf8(title),
            blob_id: string::utf8(blob_id),
            publisher: ctx.sender(),
            category: string::utf8(category),
        };
        let sender = ctx.sender();
        sui::transfer::transfer(record, sender);
    }

    public fun update_blob(
        record: &mut NoteRecord,
        new_blob_id: vector<u8>,
        ctx: &mut TxContext
    ) {
        assert!(record.publisher == ctx.sender(), 0);
        record.blob_id = string::utf8(new_blob_id);
    }

    public fun get_blob_id(record: &NoteRecord): String {
        record.blob_id
    }

    public fun get_publisher(record: &NoteRecord): address {
        record.publisher
    }
}