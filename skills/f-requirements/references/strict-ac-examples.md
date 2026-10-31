# Strict Acceptance Criteria Examples

Use these patterns when supplementing or normalizing acceptance criteria. Prefer observable outcomes + explicit Check + Must not.

## Form / UI example

### AC-1: Reject invalid email on signup
**Given** the signup form is open  
**When** the user submits "not-an-email"  
**Then** the form shows the text "Enter a valid email" under the email field  
**And** no new account is created  
**Check**: error text is present in the response or DOM; accounts store has no new row for this email  
**Must not**: existing valid signup flow is changed  
*(supplemented)*

## API example

### AC-2: Apply promo code
**Given** a cart with total 100 and valid promo "WELCOME10"  
**When** POST /checkout is called with the promo  
**Then** response status is 200 and total_after_discount equals 90  
**Check**: response JSON field total_after_discount == 90  
**Must not**: promo stacking is allowed; other cart calculation logic changes  
*(supplemented)*
