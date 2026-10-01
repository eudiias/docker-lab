import express from 'express';
import { Pool } from 'pg';
import Redis from 'ioredis';

const app = express();
const port = process.env.PORT || 3000;

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

const redis = new Redis(process.env.REDIS_URL || 'redis://redis:6379');

app.get('/health', async (_req, res) => {
    try {
        const dbRes = await pool.query('SELECT NOW()');
        await redis.set('health_check', 'ok', 'EX', 10);
        const redisRes = await redis.get('health_check');

        res.json({
            status: 'healthy',
            database: dbRes.rows[0].now,
            redis: redisRes,
        });
    } catch (error) {
        res.status(500).json({ status: 'unhealthy', error: (error as Error).message });
    }
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});