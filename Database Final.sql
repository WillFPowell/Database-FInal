-- Will did these 3 below(1-3)
-- 1. EVENT CATEGORIES
CREATE TABLE event_categories (
  category_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name          VARCHAR2(50) NOT NULL,
  CONSTRAINT uq_category_name UNIQUE (name)
);

-- 2. HOSTS (Clubs/Departments)
CREATE TABLE hosts (
  host_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name      VARCHAR2(100)    NOT NULL,
  type      VARCHAR2(20)     NOT NULL
    CONSTRAINT chk_host_type 
      CHECK (type IN ('CLUB','DEPARTMENT')),
  CONSTRAINT uq_host_name UNIQUE (name)
);

-- 3. USERS
CREATE TABLE users (
  user_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name      VARCHAR2(100)    NOT NULL,
  email     VARCHAR2(150)    NOT NULL,
  role      VARCHAR2(20)     NOT NULL
    CONSTRAINT chk_user_role 
      CHECK (role IN ('STUDENT','FACULTY','ORGANIZER')),
  CONSTRAINT uq_user_email UNIQUE (email)
);
--Joe die 4-6
-- 4. EVENTS
CREATE TABLE events (
  event_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title          VARCHAR2(100)  NOT NULL,
  description    VARCHAR2(4000) NOT NULL,
  event_date     DATE           NOT NULL,
  event_time     VARCHAR2(8)    NOT NULL,       -- stored as 'HH24:MI:SS'
  location       VARCHAR2(200)  NOT NULL,
  attendee_limit NUMBER         DEFAULT NULL,   -- NULL = unlimited
  host_id        NUMBER         NOT NULL,
  category_id    NUMBER         NOT NULL,
  CONSTRAINT fk_host
    FOREIGN KEY (host_id) REFERENCES hosts(host_id),
  CONSTRAINT fk_category
    FOREIGN KEY (category_id) REFERENCES event_categories(category_id),
  CONSTRAINT uq_event_title
    UNIQUE (title),
  CONSTRAINT uq_event_slot
    UNIQUE (event_date, event_time, location),
  CONSTRAINT chk_limit_nonneg
    CHECK (attendee_limit IS NULL OR attendee_limit > 0)
);

-- 5. RSVPS (many-to-many between USERS and EVENTS)
CREATE TABLE rsvps (
  user_id   NUMBER NOT NULL,
  event_id  NUMBER NOT NULL,
  rsvp_ts   TIMESTAMP DEFAULT SYSTIMESTAMP,
  PRIMARY KEY (user_id, event_id),
  CONSTRAINT fk_rsvp_user
    FOREIGN KEY (user_id) REFERENCES users(user_id),
  CONSTRAINT fk_rsvp_event
    FOREIGN KEY (event_id) REFERENCES events(event_id)
);

-- 6. Trigger: enforce attendee_limit
CREATE OR REPLACE TRIGGER trg_rsvp_limit
  BEFORE INSERT ON rsvps
  FOR EACH ROW
DECLARE
  v_limit NUMBER;
  v_count NUMBER;
BEGIN
  SELECT attendee_limit
    INTO v_limit
    FROM events
   WHERE event_id = :NEW.event_id;

  IF v_limit IS NOT NULL THEN
    SELECT COUNT(*) INTO v_count
      FROM rsvps
     WHERE event_id = :NEW.event_id;
    IF v_count >= v_limit THEN
      RAISE_APPLICATION_ERROR(-20001, 'Event capacity reached.');
    END IF;
  END IF;
END;
/

-- we tried to split it 50/50 between the two of us so it was pretty even
