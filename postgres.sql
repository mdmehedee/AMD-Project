--
-- PostgreSQL database dump
--

-- Dumped from database version 11.12
-- Dumped by pg_dump version 13.3

-- Started on 2021-05-31 03:53:43 CEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 16384)
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- TOC entry 3217 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


--
-- TOC entry 209 (class 1255 OID 16583)
-- Name: add_meeting(character varying, timestamp without time zone, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_meeting(place character varying, start_time timestamp without time zone, end_time timestamp without time zone, status boolean) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
	s_date timestamp = start_time;
	e_date timestamp = end_time;
	sys_date timestamp = now();
	msg character varying;

BEGIN
	IF (s_date<e_date) THEN
		IF (s_date>sys_date and e_date>sys_date) THEN
			INSERT INTO meetings VALUES(default, place, start_time, end_time, status);
			msg = 'Successfully inserted';
		ELSE
			msg = 'both cannot be set into the past';
		END IF;
	ELSE
	    msg = 'starting time of a meeting must be before ending time';
	END IF;
  	return msg;
END;
$$;


ALTER FUNCTION public.add_meeting(place character varying, start_time timestamp without time zone, end_time timestamp without time zone, status boolean) OWNER TO postgres;

--
-- TOC entry 223 (class 1255 OID 16584)
-- Name: add_study_group(integer, text, text, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_study_group(meet_id integer, subject text, details text, member_limit integer, stud_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	study_id integer;
	is_exist int = (SELECT COUNT(*) FROM group_members WHERE group_members.student_id = stud_id);
BEGIN
	IF (member_limit >= 2) THEN
		INSERT INTO study_groups VALUES(default, meet_id, subject, details, member_limit, now(),'1');
		study_id = (SELECT study_group_id FROM study_groups ORDER BY study_group_id DESC LIMIT 1);
		IF (is_exist = 0) THEN
			INSERT INTO group_members VALUES(study_id, stud_id, now(), default);
		ELSE
			DELETE FROM group_members 
			WHERE group_members.student_id = stud_id;
			insert into group_members values(study_id, stud_id, now(), default);
		END IF;
	END IF;
	
END;
$$;


ALTER FUNCTION public.add_study_group(meet_id integer, subject text, details text, member_limit integer, stud_id integer) OWNER TO postgres;

--
-- TOC entry 224 (class 1255 OID 16585)
-- Name: already_joined_group(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.already_joined_group(stud_id integer) RETURNS TABLE(sg_id integer, subject character varying, details character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
	group_id int = (SELECT study_group_id from group_members where student_id = stud_id);
BEGIN
	RETURN QUERY
	SELECT study_group_id, topic, description FROM study_groups WHERE study_group_id = group_id;
END;
$$;


ALTER FUNCTION public.already_joined_group(stud_id integer) OWNER TO postgres;

--
-- TOC entry 225 (class 1255 OID 16586)
-- Name: change_group_status(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.change_group_status(group_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	no_of_student int;
BEGIN
	no_of_student = (SELECT COUNT(*) FROM group_members 
		WHERE group_members.study_group_id = group_id);
	
	UPDATE study_groups
	SET  status = '0'
	WHERE study_groups.group_member_limit <= no_of_student;
END;
$$;


ALTER FUNCTION public.change_group_status(group_id integer) OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 16587)
-- Name: change_status_overload_group(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.change_status_overload_group(group_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	no_of_student int;
	gp_limit int;
BEGIN
	no_of_student = (SELECT COUNT(*) FROM group_members 
		WHERE group_members.study_group_id = group_id);
	gp_limit = (select study_groups.group_member_limit from study_groups where study_groups.study_group_id = group_id);
	if(no_of_student >= gp_limit) then
		UPDATE study_groups
		SET  status = '0'
		where study_groups.study_group_id = group_id;
	end if;
END;
$$;


ALTER FUNCTION public.change_status_overload_group(group_id integer) OWNER TO postgres;

--
-- TOC entry 226 (class 1255 OID 16588)
-- Name: create_study_group(integer, text, text, integer, timestamp with time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_study_group(meet_id integer, subject text, details text, student_limit integer, created_at timestamp with time zone, is_active boolean) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
	st_limit integer = student_limit;
	msg character varying;

BEGIN
	if(st_limit >= 2) then
		insert into study_groups values(default,meet_id,subject,details,student_limit, created_at, is_active);
		msg = 'successfully inserted';
	else
		msg = 'Minimum student limit 2';
	end if;
	return msg;
END;
$$;


ALTER FUNCTION public.create_study_group(meet_id integer, subject text, details text, student_limit integer, created_at timestamp with time zone, is_active boolean) OWNER TO postgres;

--
-- TOC entry 207 (class 1255 OID 16589)
-- Name: edit_group(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.edit_group(group_id integer) RETURNS TABLE(sg_id integer, meet_id integer, subject character varying, details character varying, student_limit smallint, created timestamp with time zone, isactive boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT * FROM study_groups WHERE study_group_id = group_id;
END;
$$;


ALTER FUNCTION public.edit_group(group_id integer) OWNER TO postgres;

--
-- TOC entry 208 (class 1255 OID 16590)
-- Name: edit_meeting(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.edit_meeting(meet_id integer) RETURNS TABLE(meetingid integer, place character varying, stime timestamp without time zone, etime timestamp without time zone, isactive boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT *  FROM meetings WHERE meeting_id = meet_id;
END;
$$;


ALTER FUNCTION public.edit_meeting(meet_id integer) OWNER TO postgres;

--
-- TOC entry 210 (class 1255 OID 16591)
-- Name: edit_student(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.edit_student(stud_id integer) RETURNS TABLE(studentid integer, studentname character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT student_id, student_name  FROM students WHERE student_id = stud_id;
END;
$$;


ALTER FUNCTION public.edit_student(stud_id integer) OWNER TO postgres;

--
-- TOC entry 227 (class 1255 OID 16592)
-- Name: get_all_study_groups(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_all_study_groups() RETURNS TABLE(id integer, topic character varying, description character varying, group_member_limit smallint, meeting_place character varying, start_date timestamp without time zone, end_date timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
DECLARE
	no_of_student int;
	i integer;
	all_group_id integer[] = (select array_agg(study_groups.study_group_id) from study_groups);
BEGIN
	FOREACH i IN ARRAY all_group_id
	LOOP
		perform change_status_overload_group(i);
	END LOOP;
	RETURN QUERY
	SELECT sg.study_group_id, sg.topic, sg.description, sg.group_member_limit,
	meet.meeting_place, meet.start_time, meet.end_time
	from study_groups sg
	join meetings meet on sg.meeting_id = meet.meeting_id
	where sg.status = '1';
END;
$$;


ALTER FUNCTION public.get_all_study_groups() OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 16593)
-- Name: get_all_study_groups(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_all_study_groups(incoming_meet_id integer) RETURNS TABLE(id integer, topic character varying, description character varying, group_member_limit smallint, meeting_place character varying, start_date timestamp without time zone, end_date timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
DECLARE
	no_of_student int;
	i integer;
	all_group_id integer[] = (select array_agg(study_groups.study_group_id) from study_groups);
BEGIN
	FOREACH i IN ARRAY all_group_id
	LOOP
		perform change_status_overload_group(i);
	END LOOP;
	RETURN QUERY
	SELECT sg.study_group_id, sg.topic, sg.description, sg.group_member_limit,
	meet.meeting_place, meet.start_time, meet.end_time
	from study_groups sg
	join meetings meet on sg.meeting_id = meet.meeting_id
	where sg.meeting_id = incoming_meet_id 
	and sg.status = '1';
END;
$$;


ALTER FUNCTION public.get_all_study_groups(incoming_meet_id integer) OWNER TO postgres;

--
-- TOC entry 228 (class 1255 OID 16594)
-- Name: get_meeting_detail(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_meeting_detail(meetingid integer) RETURNS integer[]
    LANGUAGE plpgsql
    AS $$
DECLARE
	i integer = 0;
	b integer;
	each_group integer[];
	no_of_groups integer = (select count(*) from study_groups where meeting_id = meetingid);
	a integer[] = (select array_agg(study_groups.study_group_id) from study_groups where meeting_id = meetingid);
BEGIN
		FOREACH i IN ARRAY a
		LOOP
			each_group = (select array_agg(student_id) from group_members where study_group_id = i);
			raise notice '%',each_group;
			
		END LOOP;
		return each_group;
END;
$$;


ALTER FUNCTION public.get_meeting_detail(meetingid integer) OWNER TO postgres;

--
-- TOC entry 229 (class 1255 OID 16595)
-- Name: get_meeting_details(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_meeting_details(meetingid integer) RETURNS TABLE(study_group_id integer, topic character varying, student_limit smallint, description character varying, no_of_student bigint, joined_stuents character varying[])
    LANGUAGE plpgsql
    AS $$
BEGIN

	RETURN QUERY
	SELECT
	sg.study_group_id,
	sg.topic,
	sg.group_member_limit,
	sg.description,
	(SELECT COUNT(*)
	 FROM group_members gm
	 WHERE sg.study_group_id = gm.study_group_id) AS no_of_students,
	 (SELECT ARRAY_AGG(s.student_name)
		FROM group_members gm JOIN
			 students s
			 ON gm.student_id = s.student_id
		WHERE sg.study_group_id = gm.study_group_id
	 ) AS student_names
	FROM 
		study_groups sg
	WHERE 
		sg.meeting_id = meetingid;
END;
$$;


ALTER FUNCTION public.get_meeting_details(meetingid integer) OWNER TO postgres;

--
-- TOC entry 230 (class 1255 OID 16596)
-- Name: get_meeting_overview(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_meeting_overview() RETURNS TABLE(id integer, location character varying, start_time timestamp without time zone, end_time timestamp without time zone, is_active boolean, no_of_groups bigint, no_of_student bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE meetings
	SET  status = '0'
	WHERE meetings.end_time <= now();
	RETURN QUERY
	SELECT meetings.meeting_id, meetings.meeting_place, meetings.start_time, meetings.end_time, meetings.status,
	(SELECT COUNT(study_groups.study_group_id) FROM study_groups 
		WHERE meetings.meeting_id = study_groups.meeting_id) AS no_of_groups, 
	(SELECT count(group_members.student_id) FROM group_members, study_groups WHERE group_members.study_group_id = study_groups.study_group_id AND study_groups.meeting_id = meetings.meeting_id) AS no_of_students FROM meetings
	where meetings.status = '1';

END;
$$;


ALTER FUNCTION public.get_meeting_overview() OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 16597)
-- Name: get_meeting_overview(timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_meeting_overview(currenttime timestamp without time zone) RETURNS TABLE(id integer, location character varying, start_time timestamp without time zone, end_time timestamp without time zone, is_active boolean, no_of_groups bigint, no_of_student bigint)
    LANGUAGE plpgsql
    AS $$
Declare
	ntime timestamp without time zone := (select LOCALTIMESTAMP);
BEGIN
	
	UPDATE meetings
	SET  status = '0'
	WHERE meetings.end_time <= currenttime;
	--select * from meetings WHERE meetings.end_time <= now();
	RETURN QUERY
	SELECT meetings.meeting_id, meetings.meeting_place, meetings.start_time, meetings.end_time, meetings.status,
	(SELECT COUNT(study_groups.study_group_id) FROM study_groups 
		WHERE meetings.meeting_id = study_groups.meeting_id) AS no_of_groups, 
	(SELECT count(group_members.student_id) FROM group_members, study_groups WHERE group_members.study_group_id = study_groups.study_group_id AND study_groups.meeting_id = meetings.meeting_id) AS no_of_students FROM meetings
	where meetings.status = '1';

END;
$$;


ALTER FUNCTION public.get_meeting_overview(currenttime timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 232 (class 1255 OID 16598)
-- Name: get_single_meeting_details(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_single_meeting_details(meetingid integer) RETURNS TABLE(g_id integer, mid integer, subject character varying, details character varying, limits smallint, created timestamp with time zone, sid integer, sname character varying)
    LANGUAGE plpgsql
    AS $$
declare
BEGIN
	RETURN QUERY
	select sg.study_group_id, sg.meeting_id, sg.topic, sg.description, sg.group_member_limit, sg.created_on, gm.student_id, st.student_name from study_groups sg inner join group_members gm on sg.study_group_id = gm.study_group_id
	inner join students st on st.student_id = gm.student_id where sg.meeting_id = meetingid;
END;
$$;


ALTER FUNCTION public.get_single_meeting_details(meetingid integer) OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 16599)
-- Name: group_owner(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.group_owner(stud_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	owner_id int;
	group_id int;
BEGIN
	group_id := (SELECT study_group_id FROM group_members WHERE student_id = stud_id);
	owner_id := (SELECT student_id FROM group_members WHERE study_group_id = group_id
	ORDER BY joined_at ASC LIMIT 1);
	RETURN owner_id;
END;
$$;


ALTER FUNCTION public.group_owner(stud_id integer) OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 16600)
-- Name: insert_update_meeting(character varying, timestamp with time zone, timestamp with time zone, boolean, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_update_meeting(place character varying, start_time timestamp with time zone, end_time timestamp with time zone, status boolean, operationname text, meetingid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
	s_date timestamp with time zone = start_time;
	e_date timestamp with time zone = end_time;
	sys_date timestamp with time zone = now();
	is_active BOOLEAN;
	message character varying;

BEGIN
	IF operationName = 'insert' THEN
	    IF ((s_date<e_date) AND (s_date>=sys_date)) THEN
	    	is_active = '0';
	    	INSERT INTO meetings(meeting_place, start_time, end_time, status) VALUES(place, start_time, end_time, status);
	    	message = 'Successfully inserted';
	    ELSE
	    	message = 'Failed to insert.';
	    END IF;
  	ELSEIF operationName = 'update' THEN
  		IF ((s_date<e_date) AND (s_date>sys_date OR s_date=sys_date)) THEN
	    	UPDATE meetings 
	    		SET meeting_place = place, start_time = s_date, end_time = e_date, status = '1'
	    		WHERE meeting_id = meetingID;
	    	message = 'Successfully updated.';
	    ELSE
	    	message = 'Failed to update.';
	    END IF;
	ELSE 
		message = 'No Insert or update.';
  	END IF;
  	return message;
END;
$$;


ALTER FUNCTION public.insert_update_meeting(place character varying, start_time timestamp with time zone, end_time timestamp with time zone, status boolean, operationname text, meetingid integer) OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 16601)
-- Name: join_study_group(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.join_study_group(stud_id integer, group_id integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
	msg character varying;
	is_exist int;
BEGIN
	is_exist = (SELECT COUNT(*) FROM group_members 
		WHERE group_members.student_id = stud_id);
	
	if(is_exist = 0) then
		insert into group_members values(group_id, stud_id, now(), default);
		msg = 'successfully joined';
	else
		DELETE FROM group_members 
		WHERE group_members.student_id = stud_id;
		insert into group_members values(group_id, stud_id, now(), default);
		msg = 'successfully changed group';
	end if;
	return msg;
END;
$$;


ALTER FUNCTION public.join_study_group(stud_id integer, group_id integer) OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 16602)
-- Name: leave_member(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.leave_member(stud_id integer, new_group_id integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE 
	no_of_student int;
	msg character varying;
	old_group_id int = (select study_group_id from group_members where student_id = stud_id);
BEGIN
	no_of_student = (SELECT COUNT(*) FROM group_members 
		WHERE group_members.study_group_id = old_group_id);
	IF (no_of_student = 1) THEN
		DELETE FROM study_groups  
		WHERE study_groups.study_group_id = new_group_id;
		delete from group_members 
		where study_group_id = new_group_id AND student_id = stud_id;
		msg = 'group has been deleted';
	elsif (new_group_id = old_group_id) then
		delete from group_members 
		where study_group_id = new_group_id AND student_id = stud_id;
		msg = 'group member has been deleted';
	--ELSE
	--	DELETE FROM group_members 
	--	WHERE group_members.student_id = stud_id;
	--	insert into group_members values(new_group_id, stud_id, now());
	--	msg = 'member deleted successfully';
	END IF;
	RETURN msg;
END;
$$;


ALTER FUNCTION public.leave_member(stud_id integer, new_group_id integer) OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 16603)
-- Name: only_hidden_meeting_list(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.only_hidden_meeting_list() RETURNS TABLE(meet_id integer, place character varying, s_time timestamp without time zone, e_time timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT meeting_id,meeting_place,start_time,end_time FROM meetings
	WHERE status = 'f' and end_time > now();
END;
$$;


ALTER FUNCTION public.only_hidden_meeting_list() OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 16604)
-- Name: only_visible_meeting_list(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.only_visible_meeting_list() RETURNS TABLE(meet_id integer, place character varying, s_time timestamp without time zone, e_time timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT meeting_id,meeting_place,start_time,end_time FROM meetings
	WHERE status = 't';
END;
$$;


ALTER FUNCTION public.only_visible_meeting_list() OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 16605)
-- Name: remove_meeting(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.remove_meeting(meetingid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE 
	isActive BOOLEAN;
	-- group_member_id int = (select group_member_id from group_members WHERE group_members.meeting_id = meetingID);
	study_group_id int = (select study_group_id from study_groups WHERE study_groups.meeting_id = meetingID);
	msg character varying;
BEGIN
	isActive := (SELECT status FROM meetings where meetings.meeting_id = meetingID);
	IF (isActive!='1') THEN
		-- IF (group_member_id) THEN
		-- DELETE FROM group_members WHERE group_members.meeting_id = meetingID;
		-- END IF;
		-- IF (study_group_id) THEN
		-- DELETE FROM study_groups WHERE study_groups.meeting_id = meetingID;
		-- END IF;
		DELETE FROM meetings WHERE meetings.meeting_id = meetingID;
		msg = 'The meeting has deleted with related data.';
	ELSE
		msg = 'This meeting is active.';
	END IF;
	RETURN msg;
END;
$$;


ALTER FUNCTION public.remove_meeting(meetingid integer) OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 24853)
-- Name: student_login(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.student_login(uname character varying, pass character varying) RETURNS TABLE(sid integer, un character varying, psw character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN 
 
   RETURN QUERY
   SELECT student_id, student_username, password 
   FROM students
   where student_username=uname and password=pass; 
     
    
END;
$$;


ALTER FUNCTION public.student_login(uname character varying, pass character varying) OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 16606)
-- Name: update_group(integer, integer, text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_group(group_id integer, incoming_id integer, subject text, details text, max_student integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare
	group_owner int = (select group_members.student_id from group_members where group_members.study_group_id = group_id
	ORDER BY joined_at ASC LIMIT 1);
	message text;
begin
	if(group_owner = incoming_id AND max_student>=2) then
		update study_groups
		set topic = subject,
			description = details,
			group_member_limit = max_student,
			status = '1'
		where study_group_id = group_id;
		message = 'successfully updated';
		
	else
		message = 'Permission denied';
	end if;
	return message;
end;
$$;


ALTER FUNCTION public.update_group(group_id integer, incoming_id integer, subject text, details text, max_student integer) OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 16607)
-- Name: update_meeting(integer, text, timestamp without time zone, timestamp without time zone, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_meeting(meet_id integer, place text, stime timestamp without time zone, etime timestamp without time zone, isactive boolean) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	update meetings 
	set meeting_place = place, start_time = stime, end_time = etime, status = isActive
	where meeting_id = meet_id;
end;
$$;


ALTER FUNCTION public.update_meeting(meet_id integer, place text, stime timestamp without time zone, etime timestamp without time zone, isactive boolean) OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 16608)
-- Name: update_meeting_status(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_meeting_status(meet_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	update meetings 
	set status = '1'
	where meeting_id = meet_id;
end;
$$;


ALTER FUNCTION public.update_meeting_status(meet_id integer) OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 16609)
-- Name: update_student(integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_student(stud_id integer, stud_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	update students set student_name = stud_name where student_id = stud_id;
end;
$$;


ALTER FUNCTION public.update_student(stud_id integer, stud_name text) OWNER TO postgres;

SET default_tablespace = '';

--
-- TOC entry 197 (class 1259 OID 16610)
-- Name: fsr_if; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fsr_if (
    fsr_if_id integer NOT NULL,
    fsr_if_username character varying(255) NOT NULL,
    password character varying(50) NOT NULL,
    created_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.fsr_if OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 16614)
-- Name: fsr_if_fsr_if_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fsr_if_fsr_if_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fsr_if_fsr_if_id_seq OWNER TO postgres;

--
-- TOC entry 3218 (class 0 OID 0)
-- Dependencies: 198
-- Name: fsr_if_fsr_if_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fsr_if_fsr_if_id_seq OWNED BY public.fsr_if.fsr_if_id;


--
-- TOC entry 199 (class 1259 OID 16616)
-- Name: group_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_members (
    study_group_id integer NOT NULL,
    student_id integer NOT NULL,
    joined_at timestamp without time zone NOT NULL,
    group_member_id bigint NOT NULL
);


ALTER TABLE public.group_members OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 16619)
-- Name: group_members_group_member_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.group_members_group_member_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.group_members_group_member_id_seq OWNER TO postgres;

--
-- TOC entry 3219 (class 0 OID 0)
-- Dependencies: 200
-- Name: group_members_group_member_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.group_members_group_member_id_seq OWNED BY public.group_members.group_member_id;


--
-- TOC entry 201 (class 1259 OID 16621)
-- Name: meetings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meetings (
    meeting_id integer NOT NULL,
    meeting_place character varying(255) NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    status boolean NOT NULL
);


ALTER TABLE public.meetings OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 16624)
-- Name: meetings_meeting_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.meetings_meeting_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.meetings_meeting_id_seq OWNER TO postgres;

--
-- TOC entry 3220 (class 0 OID 0)
-- Dependencies: 202
-- Name: meetings_meeting_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.meetings_meeting_id_seq OWNED BY public.meetings.meeting_id;


--
-- TOC entry 203 (class 1259 OID 16626)
-- Name: students; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.students (
    student_id integer NOT NULL,
    student_name character varying(50) NOT NULL,
    student_username character varying(255) NOT NULL,
    password character varying(50) NOT NULL,
    created_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.students OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 16630)
-- Name: students_student_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.students_student_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.students_student_id_seq OWNER TO postgres;

--
-- TOC entry 3221 (class 0 OID 0)
-- Dependencies: 204
-- Name: students_student_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.students_student_id_seq OWNED BY public.students.student_id;


--
-- TOC entry 205 (class 1259 OID 16632)
-- Name: study_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.study_groups (
    study_group_id integer NOT NULL,
    meeting_id integer NOT NULL,
    topic character varying(255) NOT NULL,
    description character varying(1023) NOT NULL,
    group_member_limit smallint NOT NULL,
    created_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    status boolean
);


ALTER TABLE public.study_groups OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 16639)
-- Name: study_groups_study_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.study_groups_study_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.study_groups_study_group_id_seq OWNER TO postgres;

--
-- TOC entry 3222 (class 0 OID 0)
-- Dependencies: 206
-- Name: study_groups_study_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.study_groups_study_group_id_seq OWNED BY public.study_groups.study_group_id;


--
-- TOC entry 3057 (class 2604 OID 16641)
-- Name: fsr_if fsr_if_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fsr_if ALTER COLUMN fsr_if_id SET DEFAULT nextval('public.fsr_if_fsr_if_id_seq'::regclass);


--
-- TOC entry 3058 (class 2604 OID 16642)
-- Name: group_members group_member_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_members ALTER COLUMN group_member_id SET DEFAULT nextval('public.group_members_group_member_id_seq'::regclass);


--
-- TOC entry 3059 (class 2604 OID 16643)
-- Name: meetings meeting_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetings ALTER COLUMN meeting_id SET DEFAULT nextval('public.meetings_meeting_id_seq'::regclass);


--
-- TOC entry 3061 (class 2604 OID 16644)
-- Name: students student_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students ALTER COLUMN student_id SET DEFAULT nextval('public.students_student_id_seq'::regclass);


--
-- TOC entry 3063 (class 2604 OID 16645)
-- Name: study_groups study_group_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_groups ALTER COLUMN study_group_id SET DEFAULT nextval('public.study_groups_study_group_id_seq'::regclass);


--
-- TOC entry 3202 (class 0 OID 16610)
-- Dependencies: 197
-- Data for Name: fsr_if; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fsr_if (fsr_if_id, fsr_if_username, password, created_on) FROM stdin;
\.


--
-- TOC entry 3204 (class 0 OID 16616)
-- Dependencies: 199
-- Data for Name: group_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.group_members (study_group_id, student_id, joined_at, group_member_id) FROM stdin;
28	47	2021-05-30 16:41:47.065079	54
30	46	2021-05-30 21:40:30.647912	57
31	49	2021-05-31 00:09:44.698051	58
32	50	2021-05-31 00:11:25.908505	59
33	51	2021-05-31 00:14:09.560727	60
35	52	2021-05-31 00:22:19.236902	62
33	48	2021-05-31 00:24:08.130171	63
28	54	2021-05-31 00:24:53.356286	64
34	55	2021-05-31 00:25:21.896131	65
31	56	2021-05-31 00:25:37.063583	66
35	57	2021-05-31 00:25:49.834032	67
32	58	2021-05-31 00:26:00.690153	68
\.


--
-- TOC entry 3206 (class 0 OID 16621)
-- Dependencies: 201
-- Data for Name: meetings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meetings (meeting_id, meeting_place, start_time, end_time, status) FROM stdin;
73	Wartburg	2021-06-21 16:16:00	2021-06-30 16:16:00	t
75	Bernsbachplatz	2021-06-27 14:00:00	2021-06-28 00:02:00	t
77	Zentralhaltestelle	2021-07-02 00:06:00	2021-07-03 00:06:00	f
74	Gutenbergstr	2021-06-22 22:06:00	2021-06-23 22:07:00	t
76	Annenstr	2021-06-28 00:04:00	2021-06-30 00:04:00	f
\.


--
-- TOC entry 3208 (class 0 OID 16626)
-- Dependencies: 203
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (student_id, student_name, student_username, password, created_on) FROM stdin;
46	Mehedee	Md	123	2021-05-30 16:23:51.29451+02
47	Sayem	Sm	123	2021-05-30 16:23:51.29451+02
48	Suzon	Sn	123	2021-05-30 16:23:51.29451+02
49	Mahbub	Mb	123	2021-05-30 21:50:05.200668+02
50	Syam	Syam1	123	2021-05-30 21:58:19.014093+02
51	Tusher	Tusher1	123	2021-05-30 21:58:19.014093+02
52	Shakil	Shakil1	123	2021-05-30 21:58:19.014093+02
53	Porag	Porag1	123	2021-05-30 21:58:19.014093+02
54	Tuhin	Tuhin1	123	2021-05-30 21:58:19.014093+02
55	Qusair	Qusair1	123	2021-05-30 21:58:19.014093+02
56	Oushik	Oushik1	123	2021-05-30 21:58:19.014093+02
57	Prince	Prince1	123	2021-05-30 21:58:19.014093+02
58	Sajib	Sajib1	123	2021-05-30 21:58:19.014093+02
59	Hamim	Hamim1	123	2021-05-30 21:58:19.014093+02
60	Afrad	Afrad1	123	2021-05-30 21:58:19.014093+02
61	Salman	Salman1	123	2021-05-30 21:58:19.014093+02
62	Shanto	Shanto1	123	2021-05-30 21:58:19.014093+02
63	Sobuj	Sobuj1	123	2021-05-30 21:58:19.014093+02
64	Riad	Riad1	123	2021-05-30 21:58:19.014093+02
65	Pial	Pial1	123	2021-05-30 21:58:19.014093+02
\.


--
-- TOC entry 3210 (class 0 OID 16632)
-- Dependencies: 205
-- Data for Name: study_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.study_groups (study_group_id, meeting_id, topic, description, group_member_limit, created_on, status) FROM stdin;
33	73	Hardware/Software-Codesign	The term embedded software engineering is made up of the terms embedded systems (German " embedded systems ") and software engineering (German " software technology "). An embedded system is a binary digital system (computer system) that is embedded in a surrounding technical system and interacts with it.	3	2021-05-31 00:14:09.560727+02	t
34	75	Multicore Programming	Multicore programming helps to create concurrent systems for deployment on multicore processor and multiprocessor systems. A multicore processor system is basically a single processor with multiple execution cores in one chip.	4	2021-05-31 00:18:58.131943+02	t
35	74	Design of Software for Embedded Systems	An embedded system is a microprocessor- or microcontroller-based system of hardware and software designed to perform dedicated functions within a larger mechanical or electrical system.	5	2021-05-31 00:22:19.236902+02	t
30	73	SSE	Service-oriented architectures comprise an important standard-based and technology-independent solution kit component for modern Web- and Cloud software development. SOA as a paradigm for distributed computing and the basis of modern distributed software carries a variety of benefits. Thus, there exist numerous architectural styles for identification, use, interconnection, implementation and dissemination of loosely-coupled software services and those accessible over the Internet or Web.	2	2021-05-30 18:43:07.487389+02	f
28	73	AMD	he course gives students understanding of the role and authority of data management, roles and responsibilities within data management, data architecture concepts, data management tools and techniques.	3	2021-05-30 16:41:11.315139+02	t
31	75	ASE	Automotive engineering, along with aerospace engineering and naval architecture, is a branch of vehicle engineering, incorporating elements of mechanical, electrical, electronic, software, and safety engineering as applied to the design, manufacture and operation of motorcycles, automobiles, and trucks and their respective engineering subsystems. It also includes modification of vehicles.	5	2021-05-31 00:09:44.698051+02	t
32	74	Embedded system	An embedded system is a computer system—a combination of a computer processor, computer memory, and input/output peripheral devices—that has a dedicated function within a larger mechanical or electronic system.[1][2] It is embedded as part of a complete device often including electrical or electronic hardware and mechanical parts. 	4	2021-05-31 00:11:25.908505+02	t
\.


--
-- TOC entry 3223 (class 0 OID 0)
-- Dependencies: 198
-- Name: fsr_if_fsr_if_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fsr_if_fsr_if_id_seq', 1, false);


--
-- TOC entry 3224 (class 0 OID 0)
-- Dependencies: 200
-- Name: group_members_group_member_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.group_members_group_member_id_seq', 68, true);


--
-- TOC entry 3225 (class 0 OID 0)
-- Dependencies: 202
-- Name: meetings_meeting_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.meetings_meeting_id_seq', 77, true);


--
-- TOC entry 3226 (class 0 OID 0)
-- Dependencies: 204
-- Name: students_student_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.students_student_id_seq', 65, true);


--
-- TOC entry 3227 (class 0 OID 0)
-- Dependencies: 206
-- Name: study_groups_study_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.study_groups_study_group_id_seq', 35, true);


--
-- TOC entry 3065 (class 2606 OID 16647)
-- Name: fsr_if fsr_if_fsr_if_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fsr_if
    ADD CONSTRAINT fsr_if_fsr_if_username_key UNIQUE (fsr_if_username);


--
-- TOC entry 3067 (class 2606 OID 16649)
-- Name: fsr_if fsr_if_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fsr_if
    ADD CONSTRAINT fsr_if_pkey PRIMARY KEY (fsr_if_id);


--
-- TOC entry 3069 (class 2606 OID 16651)
-- Name: group_members group_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_pkey PRIMARY KEY (group_member_id);


--
-- TOC entry 3071 (class 2606 OID 16653)
-- Name: meetings meetings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetings
    ADD CONSTRAINT meetings_pkey PRIMARY KEY (meeting_id);


--
-- TOC entry 3073 (class 2606 OID 16655)
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (student_id);


--
-- TOC entry 3075 (class 2606 OID 16657)
-- Name: students students_student_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_student_username_key UNIQUE (student_username);


--
-- TOC entry 3077 (class 2606 OID 16659)
-- Name: study_groups study_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_groups
    ADD CONSTRAINT study_groups_pkey PRIMARY KEY (study_group_id);


--
-- TOC entry 3080 (class 2606 OID 16660)
-- Name: study_groups fk_meeting; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_groups
    ADD CONSTRAINT fk_meeting FOREIGN KEY (meeting_id) REFERENCES public.meetings(meeting_id) ON DELETE CASCADE;


--
-- TOC entry 3078 (class 2606 OID 16665)
-- Name: group_members fk_student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT fk_student FOREIGN KEY (student_id) REFERENCES public.students(student_id) ON DELETE CASCADE;


--
-- TOC entry 3079 (class 2606 OID 16670)
-- Name: group_members fk_study_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT fk_study_group FOREIGN KEY (study_group_id) REFERENCES public.study_groups(study_group_id) ON DELETE CASCADE;


-- Completed on 2021-05-31 03:53:44 CEST

--
-- PostgreSQL database dump complete
--

