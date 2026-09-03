import{Queue}from"bullmq";import IORedis from"ioredis";let queue:Queue|undefined;export function importsQueue(){if(!process.env.REDIS_URL)throw new Error("REDIS_URL is required");queue??=new Queue("statement-imports",{connection:new IORedis(process.env.REDIS_URL,{maxRetriesPerRequest:null})});return queue}

