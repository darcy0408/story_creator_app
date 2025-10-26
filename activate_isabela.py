#!/usr/bin/env python3
"""
Activate Isabela Tester Profile
This script sets up the Isabela tester profile with full access to all features.
"""

import json
import os
from datetime import datetime, timedelta

def activate_isabela_tester():
    """Set Isabela as tester with family tier (all features unlocked)"""

    # Tester subscription with Family tier (has all features)
    tester_subscription = {
        'tier': 'family',
        'subscription_start_date': datetime.now().isoformat(),
        'subscription_end_date': (datetime.now() + timedelta(days=36500)).isoformat(),  # 100 years
        'is_active': True,
        'subscription_id': 'isabela_tester_profile',
    }

    # Fresh usage stats
    usage_stats = {
        'stories_created_today': 0,
        'stories_created_this_month': 0,
        'last_story_date': datetime.now().isoformat(),
        'last_reset_date': datetime.now().isoformat(),
    }

    print("=" * 60)
    print("✅ ISABELA TESTER PROFILE ACTIVATION")
    print("=" * 60)
    print()
    print("📊 Subscription Details:")
    print(f"   Tier: Family (all features unlocked)")
    print(f"   Start Date: {tester_subscription['subscription_start_date']}")
    print(f"   Expires: {tester_subscription['subscription_end_date']}")
    print(f"   Profile ID: {tester_subscription['subscription_id']}")
    print()
    print("🔓 Features Enabled:")
    print("   ✓ Unlimited stories")
    print("   ✓ Interactive choose-your-own-adventure stories")
    print("   ✓ Multi-character stories")
    print("   ✓ All 12 themes unlocked")
    print("   ✓ All companions unlocked")
    print("   ✓ Adventure map progression")
    print("   ✓ Export & share stories")
    print("   ✓ Ad-free experience")
    print("   ✓ Priority support")
    print("   ✓ Early access to features")
    print("   ✓ Up to 20 characters")
    print()
    print("=" * 60)
    print()
    print("To apply these settings, you need to:")
    print()
    print("1. In your Flutter app, add a debug button that calls:")
    print("   SubscriptionService().activateIsabelaTester()")
    print()
    print("2. Or run this in your Dart console/debug screen:")
    print()
    print("   await SubscriptionService().activateIsabelaTester();")
    print()
    print("3. Restart the app to see all features unlocked")
    print()
    print("=" * 60)
    print()
    print("📋 Subscription JSON (for manual configuration):")
    print(json.dumps(tester_subscription, indent=2))
    print()
    print("📋 Usage Stats JSON (for manual configuration):")
    print(json.dumps(usage_stats, indent=2))
    print()

if __name__ == "__main__":
    activate_isabela_tester()
