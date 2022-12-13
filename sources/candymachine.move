module candymachine::candymachine {
    use sui::coin::{Self, Coin};
    use std::string::String;
    use std::vector;
    use std::hash;
    use std::bcs;
    use std::bit_vector::{Self,BitVector};
    use sui::balance::{Self, Balance, Supply};
    use sui::object::{Self, UID};
    use sui::sui::SUI;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    const EINVALID_ROYALTY_NUMERATOR_DENOMINATOR: u64 = 3;

    struct CandyMachine has key,store {
        id:UID,
        collection_name: String,
        collection_description: String,
        baseuri: String,
        royalty_payee_address:address,
        royalty_points_denominator: u64,
        royalty_points_numerator: u64,
        presale_mint_time: u64,
        public_sale_mint_time: u64,
        presale_mint_price: u64,
        public_sale_mint_price: u64,
        paused: bool,
        total_supply: u64,
        minted: u64,
        token_mutate_setting:vector<bool>,
        candies:vector<BitVector>,
        whitelist: vector<address>,
    }
    struct Whitelist has key {
        id:UID,
        whitelist: vector<address>,
    }
    public entry fun init_candy(
        collection_name: String,
        collection_description: String,
        baseuri: String,
        royalty_payee_address:address,
        royalty_points_denominator: u64,
        royalty_points_numerator: u64,
        presale_mint_time: u64,
        public_sale_mint_time: u64,
        presale_mint_price: u64,
        public_sale_mint_price: u64,
        total_supply:u64,
        collection_mutate_setting:vector<bool>,
        token_mutate_setting:vector<bool>,
        seeds: vector<u8>,
        ctx: &mut TxContext,
    ){
        let candies_data = create_bit_mask(total_supply);
        let candymachine = CandyMachine {
            id: object::new(ctx),
            collection_name,
            collection_description,
            baseuri,
            royalty_payee_address,
            royalty_points_denominator,
            royalty_points_numerator,
            presale_mint_time,
            public_sale_mint_time,
            presale_mint_price,
            public_sale_mint_price,
            paused:false,
            total_supply,
            minted:0,
            token_mutate_setting,
            candies:candies_data,
            whitelist:vector::empty<address>()
        };
        assert!(royalty_points_denominator > 0, EINVALID_ROYALTY_NUMERATOR_DENOMINATOR);
        assert!(royalty_points_numerator <= royalty_points_denominator, EINVALID_ROYALTY_NUMERATOR_DENOMINATOR);
        transfer::transfer(candymachine, tx_context::sender(ctx));
    }

    public entry fun mint_nft(ctx: &mut TxContext,candymachine: &mut CandyMachine){
        let CandyMachine {
            collection_name,
            collection_description,
            baseuri,
            royalty_payee_address,
            royalty_points_denominator,
            royalty_points_numerator,
            presale_mint_time,
            public_sale_mint_time,
            presale_mint_price,
            public_sale_mint_price,
            total_supply,
            collection_mutate_setting,
            token_mutate_setting,
            seeds
        } = candymachine;
        let remaining = total_supply - minted;
        let random_index = pseudo_random(tx_context::sender(ctx),remaining);
        let required_position=0; // the number of unset 
        let bucket =0; // number of buckets
        let pos=0; // the mint number 
        let new =  vector::empty();
        while (required_position < random_index)
        {
        let bitvector=*vector::borrow_mut(&mut candy_data.candies, bucket);
        let i =0;
        while (i < bit_vector::length(&bitvector)) {
            if (!bit_vector::is_index_set(&bitvector, i))
            {
            required_position=required_position+1;
            };
            if (required_position == random_index)
            {
                bit_vector::set(&mut bitvector,i);
                vector::push_back(&mut new, bitvector);
                break
            };
            pos=pos+1;
            i= i + 1;
        };
        vector::push_back(&mut new, bitvector);
        bucket=bucket+1
        };
        while (bucket < vector::length(&candy_data.candies))
        {
            let bitvector=*vector::borrow_mut(&mut candy_data.candies, bucket);
            vector::push_back(&mut new, bitvector);
            bucket=bucket+1;
        };

        let mint_position = pos;

        candy_data.candies = new;
    }
    fun create_bit_mask(nfts: u64): vector<BitVector>
    {
        let full_buckets = nfts/1024; 
        let remaining =nfts-full_buckets*1024; 
        if (nfts < 1024)
        {
            full_buckets=0;
            remaining= nfts;
        };
        let v1 = vector::empty();
        while (full_buckets>0)
        {
            let new = bit_vector::new(1023); 
            vector::push_back(&mut v1, new);
            full_buckets=full_buckets-1;
        };
        vector::push_back(&mut v1,bit_vector::new(remaining));
        v1
    }
    //takes the random number between 1 to total supply as index
    // returns the index among the available
    fun mint_available_number(index:u64,data:vector<BitVector>):(u64,vector<BitVector>)
    {
        let required_position=0; // the number of unset 
        let bucket =0; // number of buckets
        let pos=0; // the mint number 
        while (required_position < index)
        {
        let bitvector=*vector::borrow_mut(&mut data, bucket);
        let i =0;
        while (i < bit_vector::length(&bitvector)) {
            if (!bit_vector::is_index_set(&bitvector, i))
            {
            required_position=required_position+1;
            };
            pos=pos+1;
            if (required_position == index)
            {
                bit_vector::set(&mut bitvector,i);
                break
            };
            i= i + 1;
        };
        bucket=bucket+1
        };
        (pos,
        data)
    }
    fun pseudo_random(add:address,remaining:u64):u64
    {
        let x = bcs::to_bytes<address>(&add);
        let y = bcs::to_bytes<u64>(&remaining);
        // let z = bcs::to_bytes<u64>(&timestamp::now_seconds());
        vector::append(&mut x,y);
        // vector::append(&mut x,z);
        let tmp = hash::sha2_256(x);

        let data = vector<u8>[];
        let i =24;
        while (i < 32)
        {
            let x =vector::borrow(&tmp,i);
            vector::append(&mut data,vector<u8>[*x]);
            i= i+1;
        };
        assert!(remaining>0,999);

        let random = to_u64(data) % remaining + 1;
        if (random == 0 )
        {
            random = 1;
        };
        random

    }
    public(friend) native fun from_bytes<T>(bytes: vector<u8>): T;
    public fun to_u64(v: vector<u8>): u64 {
        from_bytes<u64>(v)
    }
}