import os
import random
import csv
from faker import Faker
from dotenv import load_dotenv

load_dotenv()

SEED = int(os.getenv('SEED', 42))
SEED_COUNT = int(os.getenv('SEED_COUNT', 100))
random.seed(SEED)
Faker.seed(SEED)
faker = Faker()

N_USERS = SEED_COUNT
N_PUBLICS = max(SEED_COUNT // 5, 1)
N_FRIENDS = SEED_COUNT * 3
N_FOLLOWERS = SEED_COUNT * 4
N_PUBLIC_SUBS = SEED_COUNT * 4

os.makedirs('/data', exist_ok=True)

# Users
users = []
for i in range(1, N_USERS + 1):
    users.append({
        'id': i,
        'name': faker.name(),
        'email': faker.unique.email(),
        'created_at': faker.date_between(start_date='-3y', end_date='today').isoformat()
    })
with open('/data/users.csv', 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=users[0].keys())
    writer.writeheader()
    writer.writerows(users)

# Publics
publics = []
for i in range(1, N_PUBLICS + 1):
    publics.append({
        'id': i,
        'name': f'Public_{i}',
        'description': faker.sentence(),
        'created_at': faker.date_between(start_date='-3y', end_date='today').isoformat()
    })
with open('/data/publics.csv', 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=publics[0].keys())
    writer.writeheader()
    writer.writerows(publics)

def unique_pairs(n_people, n_pairs):
    result = set()
    while len(result) < n_pairs:
        a, b = random.sample(range(1, n_people + 1), 2)
        pair = tuple(sorted((a, b)))
        if pair not in result:
            result.add(pair)
    return list(result)

# Friends (unique pairs)
friends = unique_pairs(N_USERS, N_FRIENDS)
with open('/data/friends.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['person1_id', 'person2_id', 'created_at'])
    for a, b in friends:
        writer.writerow([a, b, faker.date_between(start_date='-3y', end_date='today').isoformat()])

# Followers (directed, no self)
followers = set()
while len(followers) < N_FOLLOWERS:
    a, b = random.sample(range(1, N_USERS + 1), 2)
    if (a, b) not in followers:
        followers.add((a, b))
with open('/data/followers.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['follower_id', 'following_id', 'created_at'])
    for a, b in followers:
        writer.writerow([a, b, faker.date_between(start_date='-3y', end_date='today').isoformat()])

# Public subscriptions
public_subs = set()
while len(public_subs) < N_PUBLIC_SUBS:
    person = random.randint(1, N_USERS)
    public = random.randint(1, N_PUBLICS)
    if (person, public) not in public_subs:
        public_subs.add((person, public))
with open('/data/public_subs.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['person_id', 'public_id', 'created_at'])
    for person, public in public_subs:
        writer.writerow([person, public, faker.date_between(start_date='-3y', end_date='today').isoformat()])
