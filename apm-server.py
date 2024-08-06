from fastapi import FastAPI, Response, status
from pydantic import BaseModel

app = FastAPI()


class Team(BaseModel):
    id: int
    actions: int


teams = {}
NO_CONTENT = Response(content="", status_code=status.HTTP_204_NO_CONTENT)


@app.get("/ping")
async def read_ping():
    return Response(content="pong")

@app.get("/teams")
def read_teams():
    return teams

@app.get("/team/{team_id}/test")
def test_team(team_id: int):
    return Response(content="ok")

@app.get("/team/{team_id}/reset")
def reset_team(team_id: int):
    teams[team_id] = Team(id=team_id, actions=0)
    return NO_CONTENT

@app.get("/team/{team_id}/actions")
def update_actions(team_id: int, action_delta: int):
    if team_id not in teams:
        reset_team(team_id)

    teams[team_id].actions += action_delta
    return Response(content=str(teams[team_id].actions))

@app.get("/team/{team_id}/delete")
def delete_team(team_id: int):
    teams.pop(team_id, None)
    return NO_CONTENT
