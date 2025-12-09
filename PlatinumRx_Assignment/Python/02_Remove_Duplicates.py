def remove_duplicates_keep_order(s: str) -> str:
    result = []
    seen = set()
    for ch in s:
        if ch not in seen:
            seen.add(ch)
            result.append(ch)
    return ''.join(result)

if __name__ == '__main__':
    print(remove_duplicates_keep_order('banana'))
    print(remove_duplicates_keep_order('abracadabra'))
