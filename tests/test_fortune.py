from fortune.fortune import Fortune


def test_create_fortune():
    fortune = Fortune("Test fortune", 1)

    assert fortune.text == "Test fortune"
    assert fortune.id == 1


def test_load_fortunes():
    fortunes = Fortune()._load_fortunes()

    assert len(fortunes) > 0
    assert all(isinstance(fortune, Fortune) for fortune in fortunes)


def test_fortune_ids_are_unique():
    fortunes = Fortune()._load_fortunes()

    ids = [fortune.id for fortune in fortunes]

    assert len(ids) == len(set(ids))


def test_get_fortune_by_id():
    fortunes = Fortune()._load_fortunes()

    first_fortune = fortunes[0]

    result = Fortune().get_fortune_by_id(first_fortune.id)

    assert result is not None
    assert result.id == first_fortune.id
    assert result.text == first_fortune.text


def test_get_fortune_by_invalid_id():
    result = Fortune().get_fortune_by_id(-1)

    assert result is None


def test_get_random_fortune():
    fortune = Fortune().get_random_fortune()

    assert isinstance(fortune, Fortune)
    assert fortune.id > 0
    assert fortune.text

