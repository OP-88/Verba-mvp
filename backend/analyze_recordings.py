#!/usr/bin/env python3
"""
Test with a real user recording from the database
"""
import sqlite3
import subprocess
import sys
sys.path.insert(0, '/home/marc/Verba-mvp/backend')

DB_PATH = '/home/marc/Verba-mvp/backend/verba_sessions.db'

print("Checking existing recordings for patterns...")
conn = sqlite3.connect(DB_PATH)
cursor = conn.execute("""
    SELECT 
        datetime(created_at, 'localtime') as time,
        length(transcript) as len,
        CASE 
            WHEN transcript LIKE '%I don''t know%' OR transcript LIKE '%I''m not sure%' THEN 'HALLUCINATION'
            WHEN length(transcript) < 50 THEN 'TOO_SHORT'
            WHEN length(transcript) > 1000 THEN 'GOOD_LENGTH'
            ELSE 'MODERATE'
        END as status,
        substr(transcript, 1, 100) as preview
    FROM sessions 
    WHERE created_at > '2025-12-06'
    ORDER BY created_at DESC
    LIMIT 10
""")

print("\nRecent recordings analysis:")
print("="*80)
for row in cursor:
    time, length, status, preview = row
    print(f"{time} | {length:4d} chars | {status:15s} | {preview[:60]}...")

conn.close()
print("="*80)
