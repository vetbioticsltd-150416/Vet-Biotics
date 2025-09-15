import { Collection, Db, Filter, FindOptions, InsertOneOptions, MongoClient, ObjectId, UpdateFilter, UpdateOptions } from 'mongodb';
import { BaseEntity } from '../models/base';

export class DatabaseService {
    private client: MongoClient;
    private db: Db;

    constructor(connectionString: string, databaseName: string) {
        this.client = new MongoClient(connectionString);
        this.db = this.client.db(databaseName);
    }

    async connect(): Promise<void> {
        try {
            await this.client.connect();
            console.log('Connected to MongoDB');
        } catch (error) {
            console.error('Failed to connect to MongoDB:', error);
            throw error;
        }
    }

    async disconnect(): Promise<void> {
        await this.client.close();
        console.log('Disconnected from MongoDB');
    }

    // Generic CRUD operations
    async findOne<T extends BaseEntity>(
        collectionName: string,
        filter: Filter<T>,
        options?: FindOptions
    ): Promise<T | null> {
        const collection = this.db.collection<T>(collectionName);
        return await collection.findOne(filter, options);
    }

    async find<T extends BaseEntity>(
        collectionName: string,
        filter: Filter<T> = {},
        options?: FindOptions
    ): Promise<T[]> {
        const collection = this.db.collection<T>(collectionName);
        const cursor = collection.find(filter, options);
        return await cursor.toArray();
    }

    async findWithPagination<T extends BaseEntity>(
        collectionName: string,
        filter: Filter<T> = {},
        page: number = 1,
        limit: number = 20,
        sort?: Record<string, 1 | -1>
    ): Promise<{ data: T[]; total: number; totalPages: number }> {
        const collection = this.db.collection<T>(collectionName);

        const skip = (page - 1) * limit;
        const total = await collection.countDocuments(filter);
        const totalPages = Math.ceil(total / limit);

        const options: FindOptions = {
            skip,
            limit,
            sort
        };

        const data = await collection.find(filter, options).toArray();

        return { data, total, totalPages };
    }

    async insertOne<T extends BaseEntity>(
        collectionName: string,
        document: Omit<T, '_id'>,
        options?: InsertOneOptions
    ): Promise<ObjectId> {
        const collection = this.db.collection<T>(collectionName);

        // Add timestamps
        const now = new Date();
        const docWithTimestamps = {
            ...document,
            createdAt: now,
            updatedAt: now,
            isActive: true,
            version: 1
        } as T;

        const result = await collection.insertOne(docWithTimestamps, options);
        return result.insertedId;
    }

    async insertMany<T extends BaseEntity>(
        collectionName: string,
        documents: Omit<T, '_id'>[],
        options?: any
    ): Promise<ObjectId[]> {
        const collection = this.db.collection<T>(collectionName);

        const now = new Date();
        const docsWithTimestamps = documents.map(doc => ({
            ...doc,
            createdAt: now,
            updatedAt: now,
            isActive: true,
            version: 1
        })) as T[];

        const result = await collection.insertMany(docsWithTimestamps, options);
        return Object.values(result.insertedIds);
    }

    async updateOne<T extends BaseEntity>(
        collectionName: string,
        filter: Filter<T>,
        update: UpdateFilter<T>,
        options?: UpdateOptions
    ): Promise<boolean> {
        const collection = this.db.collection<T>(collectionName);

        // Add updated timestamp
        const updateWithTimestamp: UpdateFilter<T> = {
            ...update,
            $set: {
                ...update.$set,
                updatedAt: new Date()
            }
        };

        const result = await collection.updateOne(filter, updateWithTimestamp, options);
        return result.modifiedCount > 0;
    }

    async updateMany<T extends BaseEntity>(
        collectionName: string,
        filter: Filter<T>,
        update: UpdateFilter<T>,
        options?: UpdateOptions
    ): Promise<number> {
        const collection = this.db.collection<T>(collectionName);

        // Add updated timestamp
        const updateWithTimestamp: UpdateFilter<T> = {
            ...update,
            $set: {
                ...update.$set,
                updatedAt: new Date()
            }
        };

        const result = await collection.updateMany(filter, updateWithTimestamp, options);
        return result.modifiedCount;
    }

    async deleteOne<T extends BaseEntity>(
        collectionName: string,
        filter: Filter<T>
    ): Promise<boolean> {
        const collection = this.db.collection<T>(collectionName);

        // Soft delete
        const result = await collection.updateOne(filter, {
            $set: {
                isDeleted: true,
                deletedAt: new Date(),
                updatedAt: new Date()
            }
        });

        return result.modifiedCount > 0;
    }

    async hardDeleteOne<T extends BaseEntity>(
        collectionName: string,
        filter: Filter<T>
    ): Promise<boolean> {
        const collection = this.db.collection<T>(collectionName);
        const result = await collection.deleteOne(filter);
        return result.deletedCount > 0;
    }

    async countDocuments<T extends BaseEntity>(
        collectionName: string,
        filter: Filter<T> = {}
    ): Promise<number> {
        const collection = this.db.collection<T>(collectionName);
        return await collection.countDocuments(filter);
    }

    // Aggregation operations
    async aggregate<T>(
        collectionName: string,
        pipeline: any[]
    ): Promise<T[]> {
        const collection = this.db.collection(collectionName);
        const cursor = collection.aggregate(pipeline);
        return await cursor.toArray() as T[];
    }

    // Transaction support
    async withTransaction<T>(
        callback: (session: any) => Promise<T>
    ): Promise<T> {
        const session = this.client.startSession();
        try {
            let result: T;
            await session.withTransaction(async () => {
                result = await callback(session);
            });
            return result!;
        } finally {
            await session.endSession();
        }
    }

    // Index management
    async createIndex(
        collectionName: string,
        keys: Record<string, 1 | -1>,
        options?: any
    ): Promise<string> {
        const collection = this.db.collection(collectionName);
        return await collection.createIndex(keys, options);
    }

    async createUniqueIndex(
        collectionName: string,
        keys: Record<string, 1 | -1>,
        options?: any
    ): Promise<string> {
        const collection = this.db.collection(collectionName);
        return await collection.createIndex(keys, { ...options, unique: true });
    }

    // Collection management
    getCollection<T extends BaseEntity>(collectionName: string): Collection<T> {
        return this.db.collection<T>(collectionName);
    }
}
