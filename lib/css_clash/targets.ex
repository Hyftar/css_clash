defmodule CssClash.Targets do
  alias CssClash.Repo
  alias CssClash.Targets.Target
  alias CssClash.Targets.Submission

  import Ecto.Query

  @doc """
  Returns the list of targets.

  ## Examples

      iex> list_targets()
      [%Target{}, ...]

  """
  def list_targets do
    Repo.all(Target)
  end

  @doc """
  Gets a single target.

  Raises `Ecto.NoResultsError` if the Target does not exist.

  ## Examples

      iex> get_target!(123)
      %Target{}

      iex> get_target!(456)
      ** (Ecto.NoResultsError)

  """
  def get_target!(id), do: Repo.get!(Target, id)

  @doc """
  Gets a single target by slug.

  Raises `Ecto.NoResultsError` if the Target does not exist.

  ## Examples

      iex> get_target_by_slug!("some-uuid-slug")
      %Target{}

      iex> get_target_by_slug!("nonexistent-slug")
      ** (Ecto.NoResultsError)

  """
  def get_target_by_slug!(slug), do: Repo.get_by!(Target, slug: slug)

  @doc """
  Creates a target.

  ## Examples

      iex> create_target(%{field: value})
      {:ok, %Target{}}

      iex> create_target(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_target(attrs) do
    %Target{}
    |> Target.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a target.

  ## Examples

      iex> update_target(target, %{field: new_value})
      {:ok, %Target{}}

      iex> update_target(target, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_target(%Target{} = target, attrs) do
    target
    |> Target.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a target.

  ## Examples

      iex> delete_target(target)
      {:ok, %Target{}}

      iex> delete_target(target)
      {:error, %Ecto.Changeset{}}

  """
  def delete_target(%Target{} = target) do
    Repo.delete(target)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking target changes.

  ## Examples

      iex> change_target(target)
      %Ecto.Changeset{data: %Target{}}

  """
  def change_target(%Target{} = target, attrs \\ %{}) do
    Target.changeset(target, attrs)
  end

  def get_success_rate(target_id) do
    from(
      s in Submission,
      where: s.target_id == ^target_id and s.score == 1.0,
      group_by: [s.target_id],
      select:
        count(s.user_id, :distinct) /
          fragment(
            "cast(? as float)",
            subquery(
              from(
                s in Submission,
                where: s.target_id == ^target_id,
                group_by: [s.target_id],
                select: fragment("GREATEST(?, 1)", count(s.user_id, :distinct))
              )
            )
          )
    )
    |> Repo.one()
  end

  def count_players(target_id) do
    from(
      s in Submission,
      where: s.target_id == ^target_id,
      group_by: [s.target_id],
      select: count(s.user_id, :distinct)
    )
    |> Repo.one()
  end

  def get_user_highscore(target_id, user_id) do
    from(
      s in Submission,
      where: s.target_id == ^target_id and s.user_id == ^user_id,
      select: max(s.score)
    )
    |> Repo.one()
  end

  def count_submissions(target_id, user_id) do
    from(
      s in Submission,
      where: s.target_id == ^target_id and s.user_id == ^user_id and not is_nil(s.score),
      select: count(s.id)
    )
    |> Repo.one()
  end

  def count_submissions(target_id) do
    from(
      s in Submission,
      where: s.target_id == ^target_id and not is_nil(s.score),
      select: count(s.id)
    )
    |> Repo.one()
  end

  def create_or_get_latest_submission(user_id, target_id) do
    from(
      s in Submission,
      where: s.user_id == ^user_id and s.target_id == ^target_id,
      order_by: [desc: s.inserted_at],
      limit: 1
    )
    |> Repo.one()
    |> then(fn
      nil -> create_submission(%{user_id: user_id, target_id: target_id})
      submission -> {:ok, submission}
    end)
  end

  def create_submission(attrs) do
    %Submission{}
    |> Submission.changeset(attrs)
    |> Repo.insert()
  end

  def update_submission(%Submission{} = submission, attrs) do
    submission
    |> Submission.changeset(attrs)
    |> Repo.update()
  end

  def submit_submission(%Submission{} = submission, attrs) do
    submission
    |> Submission.submit_changeset(attrs)
    |> Repo.update()
  end
end
