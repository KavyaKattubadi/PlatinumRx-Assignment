def minutes_to_readable(total_minutes: int) -> str:
    if total_minutes < 0:
        raise ValueError("minutes must be non-negative")
    hours = total_minutes // 60
    minutes = total_minutes % 60
    hour_label = "hr" if hours == 1 else "hrs"
    minute_label = "minute" if minutes == 1 else "minutes"
    if hours and minutes:
        return f"{hours} {hour_label} {minutes} {minute_label}"
    elif hours:
        return f"{hours} {hour_label}"
    else:
        return f"{minutes} {minute_label}"

if __name__ == '__main__':
    print(minutes_to_readable(130))
    print(minutes_to_readable(110))
